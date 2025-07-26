#!/usr/bin/env python3
"""
WebSocket摄像头客户端测试脚本
用于测试websocket_camera.py服务
"""

import asyncio
import websockets
import json
import base64
import time
from PIL import Image
from io import BytesIO
import cv2
import numpy as np

class WebSocketCameraClient:
    def __init__(self, server_url="ws://localhost:8765"):
        self.server_url = server_url
        self.websocket = None
        self.frame_count = 0
        self.last_frame_time = 0
        self.fps = 0
        
    async def connect(self):
        """连接到WebSocket服务器"""
        try:
            self.websocket = await websockets.connect(self.server_url)
            print(f"✅ 已连接到服务器: {self.server_url}")
            return True
        except Exception as e:
            print(f"❌ 连接失败: {e}")
            return False
    
    async def receive_frames(self):
        """接收图像帧"""
        try:
            while True:
                # 接收消息
                message = await self.websocket.recv()
                data = json.loads(message)
                
                if data["type"] == "image":
                    # 解码base64图像
                    img_data = base64.b64decode(data["data"])
                    
                    # 转换为PIL图像
                    pil_image = Image.open(BytesIO(img_data))
                    
                    # 转换为OpenCV格式
                    cv_image = cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR)
                    
                    # 显示图像
                    cv2.imshow("WebSocket Camera", cv_image)
                    
                    # 更新统计信息
                    self.frame_count += 1
                    current_time = time.time()
                    
                    if self.last_frame_time > 0:
                        frame_time = current_time - self.last_frame_time
                        self.fps = 1.0 / frame_time
                        
                        # 计算延迟
                        latency = (current_time - data["timestamp"]) * 1000
                        
                        print(f"帧数: {self.frame_count}, FPS: {self.fps:.1f}, 延迟: {latency:.1f}ms")
                    
                    self.last_frame_time = current_time
                    
                    # 按'q'键退出
                    if cv2.waitKey(1) & 0xFF == ord('q'):
                        break
                        
                elif data["type"] == "error":
                    print(f"服务器错误: {data['message']}")
                    
        except websockets.exceptions.ConnectionClosed:
            print("连接已关闭")
        except Exception as e:
            print(f"接收数据错误: {e}")
    
    async def close(self):
        """关闭连接"""
        if self.websocket:
            await self.websocket.close()
            print("连接已关闭")
        cv2.destroyAllWindows()

async def main():
    """主函数"""
    import sys
    
    # 获取服务器地址
    server_url = "ws://localhost:8765"
    if len(sys.argv) > 1:
        server_url = sys.argv[1]
    
    print(f"🚀 连接到WebSocket摄像头服务器: {server_url}")
    print("💡 按 'q' 键退出")
    
    client = WebSocketCameraClient(server_url)
    
    try:
        # 连接服务器
        if await client.connect():
            # 接收图像帧
            await client.receive_frames()
    except KeyboardInterrupt:
        print("\n⏹️  用户中断")
    except Exception as e:
        print(f"❌ 错误: {e}")
    finally:
        await client.close()

if __name__ == "__main__":
    asyncio.run(main()) 