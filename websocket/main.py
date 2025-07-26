import cv2
import numpy as np
from flask import Flask, Response, request
import threading
import time
import socket

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

# 创建Flask应用
app = Flask(__name__)

@app.route('/camera.jpg')
@app.route('/camera.jpeg')
@app.route('/camera.png')
@app.route('/img')
@app.route('/image')
@app.route('/snapshot')
def get_image():
    """获取摄像头图片 - 支持多种URL格式"""
    frame = camera_stream.get_frame()
    if frame is not None:
        # 根据URL路径选择图片格式
        if request.path.endswith('.png'):
            ret, buffer = cv2.imencode('.png', frame)
            mimetype = 'image/png'
        else:
            ret, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 95])
            mimetype = 'image/jpeg'
        
        if ret:
            response = Response(buffer.tobytes(), mimetype=mimetype)
            response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
            response.headers['Pragma'] = 'no-cache'
            response.headers['Expires'] = '0'
            return response
    
    # 如果没有帧，返回错误
    return "无法获取摄像头图像", 500

@app.route('/')
def index():
    """简单的状态页面"""
    return "摄像头服务运行中 - 访问 /camera.jpg 获取图片"

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

def main():
    """主函数"""
    try:
        # 启动摄像头
        camera_stream.start()
        
        # 获取本机IP地址
        local_ip = get_local_ip()
        
        print("🚀 摄像头服务启动中...")
        print("=" * 50)
        print("📱 本地访问:")
        print(f"   http://localhost:5010/camera.jpg")
        print(f"   http://127.0.0.1:5010/camera.jpg")
        print()
        print("🌐 局域网访问:")
        print(f"   http://{local_ip}:5010/camera.jpg")
        print("=" * 50)
        print("💡 支持的URL格式:")
        print("   • /camera.jpg  - JPEG格式")
        print("   • /camera.png  - PNG格式") 
        print("   • /img         - JPEG格式")
        print("   • /image       - JPEG格式")
        print("   • /snapshot    - JPEG格式")
        print("⏹️  按 Ctrl+C 停止服务")
        
        # 启动Flask服务器
        app.run(host='0.0.0.0', port=5010, debug=False, threaded=True)
        
    except KeyboardInterrupt:
        print("\n⏹️  正在停止服务...")
    except Exception as e:
        print(f"❌ 错误: {e}")
    finally:
        camera_stream.stop()
        print("✅ 服务已停止")

if __name__ == '__main__':
    main()
