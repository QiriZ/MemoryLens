import cv2
import numpy as np
import asyncio
import websockets
import json
import base64
import threading
import time
import socket
from io import BytesIO
from PIL import Image

class CameraStream:
    def __init__(self, camera_index=0):
        self.camera_index = camera_index
        self.camera = None
        self.frame = None
        self.is_running = False
        self.lock = threading.Lock()
        
    def start(self):
        """启动摄像头"""
        self.camera = cv2.VideoCapture(self.camera_index)
        if not self.camera.isOpened():
            raise RuntimeError(f"无法打开摄像头 {self.camera_index}")
        
        self.is_running = True
        self.thread = threading.Thread(target=self._update_frame)
        self.thread.daemon = True
        self.thread.start()
        print(f"摄像头 {self.camera_index} 已启动")
        
    def _update_frame(self):
        """在后台线程中持续更新帧"""
        while self.is_running:
            ret, frame = self.camera.read()
            if ret:
                with self.lock:
                    self.frame = frame.copy()
            else:
                print("无法读取摄像头帧")
                break
            time.sleep(0.03)  # 约30 FPS
            
    def get_frame(self):
        """获取当前帧"""
        with self.lock:
            if self.frame is not None:
                return self.frame.copy()
            return None
            
    def stop(self):
        """停止摄像头"""
        self.is_running = False
        if self.camera:
            self.camera.release()
        print("摄像头已停止")

# 创建摄像头实例
camera_stream = CameraStream()

def get_local_ip():
    """获取本机局域网IP地址"""
    try:
        # 创建一个UDP socket连接到外部地址来获取本机IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        # 如果上面的方法失败，尝试其他方法
        try:
            hostname = socket.gethostname()
            return socket.gethostbyname(hostname)
        except Exception:
            return "127.0.0.1"

def frame_to_base64(frame, quality=80):
    """将OpenCV帧转换为base64编码的JPEG"""
    try:
        # 将BGR转换为RGB
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # 转换为PIL图像
        pil_image = Image.fromarray(frame_rgb)
        
        # 保存为JPEG格式的字节流
        buffer = BytesIO()
        pil_image.save(buffer, format='JPEG', quality=quality)
        
        # 转换为base64
        img_str = base64.b64encode(buffer.getvalue()).decode('utf-8')
        return img_str
    except Exception as e:
        print(f"图像编码错误: {e}")
        return None

async def camera_handler(websocket, path):
    """处理WebSocket连接"""
    print(f"新的WebSocket连接: {websocket.remote_address}")
    
    try:
        while True:
            # 获取摄像头帧
            frame = camera_stream.get_frame()
            
            if frame is not None:
                # 转换为base64编码
                img_base64 = frame_to_base64(frame)
                
                if img_base64:
                    # 发送图像数据
                    message = {
                        "type": "image",
                        "data": img_base64,
                        "timestamp": time.time()
                    }
                    await websocket.send(json.dumps(message))
                else:
                    # 发送错误消息
                    error_msg = {
                        "type": "error",
                        "message": "无法获取图像"
                    }
                    await websocket.send(json.dumps(error_msg))
            else:
                # 发送错误消息
                error_msg = {
                    "type": "error",
                    "message": "摄像头未就绪"
                }
                await websocket.send(json.dumps(error_msg))
            
            # 等待一小段时间
            await asyncio.sleep(0.1)  # 10 FPS
            
    except websockets.exceptions.ConnectionClosed:
        print(f"WebSocket连接关闭: {websocket.remote_address}")
    except Exception as e:
        print(f"WebSocket处理错误: {e}")

async def main():
    """主函数"""
    try:
        # 启动摄像头
        camera_stream.start()
        
        # 获取本机IP地址
        local_ip = get_local_ip()
        
        print("🚀 WebSocket摄像头服务启动中...")
        print("=" * 60)
        print("📱 本地访问:")
        print(f"   ws://localhost:8765")
        print(f"   ws://127.0.0.1:8765")
        print()
        print("🌐 局域网访问:")
        print(f"   ws://{local_ip}:8765")
        print("=" * 60)
        print("💡 使用说明:")
        print("   • 连接WebSocket后会自动接收图像数据")
        print("   • 图像数据以JSON格式发送，包含base64编码的图像")
        print("   • 支持多个客户端同时连接")
        print("⏹️  按 Ctrl+C 停止服务")
        
        # 启动WebSocket服务器
        server = await websockets.serve(camera_handler, "0.0.0.0", 8765)
        print("✅ WebSocket服务器已启动")
        
        # 保持服务器运行
        await server.wait_closed()
        
    except KeyboardInterrupt:
        print("\n⏹️  正在停止服务...")
    except Exception as e:
        print(f"❌ 错误: {e}")
    finally:
        camera_stream.stop()
        print("✅ 服务已停止")

if __name__ == '__main__':
    asyncio.run(main()) 