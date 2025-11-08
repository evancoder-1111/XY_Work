// 星元空间 统一数字门户 - 公共脚本

// Toast 通知函数
function showToast(message, type = 'success') {
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.textContent = message;
  document.body.appendChild(toast);
  
  setTimeout(() => {
    toast.style.animation = 'slideOut 0.3s ease-out';
    setTimeout(() => {
      document.body.removeChild(toast);
    }, 300);
  }, 3000);
}

// 添加 slideOut 动画
const style = document.createElement('style');
style.textContent = `
  @keyframes slideOut {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(100%);
      opacity: 0;
    }
  }
`;
document.head.appendChild(style);

// 表单验证
function validateForm(formElement) {
  const inputs = formElement.querySelectorAll('input[required]');
  let isValid = true;
  
  inputs.forEach(input => {
    if (!input.value.trim()) {
      isValid = false;
      input.classList.add('error');
      const errorMsg = input.parentElement.querySelector('.error-message');
      if (errorMsg) {
        errorMsg.style.display = 'block';
      }
    } else {
      input.classList.remove('error');
      const errorMsg = input.parentElement.querySelector('.error-message');
      if (errorMsg) {
        errorMsg.style.display = 'none';
      }
    }
  });
  
  return isValid;
}

// 模拟 API 请求
function mockApiRequest(url, data = {}) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({ success: true, data });
    }, 500);
  });
}

// 格式化日期
function formatDate(date) {
  const d = new Date(date);
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}年${month}月${day}日`;
}

// 格式化时间
function formatTime(date) {
  const d = new Date(date);
  const hours = String(d.getHours()).padStart(2, '0');
  const minutes = String(d.getMinutes()).padStart(2, '0');
  return `${hours}:${minutes}`;
}

// 获取相对时间
function getRelativeTime(date) {
  const now = new Date();
  const diff = now - new Date(date);
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);
  
  if (minutes < 1) return '刚刚';
  if (minutes < 60) return `${minutes}分钟前`;
  if (hours < 24) return `${hours}小时前`;
  if (days < 7) return `${days}天前`;
  return formatDate(date);
}

// 防抖函数
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// 节流函数
function throttle(func, limit) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

// 自动刷新功能 - 实时预览
(function() {
  // 默认启用实时预览模式（可以通过 URL 参数 ?dev=false 禁用）
  const urlParams = new URLSearchParams(window.location.search);
  const isDevMode = urlParams.get('dev') !== 'false';
  
  if (!isDevMode) return;
  
  let lastContentLength = null;
  let lastETag = null;
  const currentFile = window.location.pathname.split('/').pop() || 'index.html';
  
  // 检查文件是否更新
  async function checkFileUpdate() {
    try {
      const response = await fetch(currentFile + '?t=' + Date.now(), {
        method: 'HEAD',
        cache: 'no-cache'
      });
      
      const contentLength = response.headers.get('Content-Length');
      const etag = response.headers.get('ETag');
      const lastModified = response.headers.get('Last-Modified');
      
      // 使用多种方法检测文件更新
      const isUpdated = 
        (lastContentLength && contentLength && contentLength !== lastContentLength) ||
        (lastETag && etag && etag !== lastETag) ||
        (lastModified && document.lastModified && new Date(lastModified).getTime() !== new Date(document.lastModified).getTime());
      
      if (isUpdated) {
        // 文件已更新，显示提示并刷新
        showRefreshNotification();
        setTimeout(() => {
          window.location.reload();
        }, 500);
        return;
      }
      
      // 记录当前状态
      if (contentLength) lastContentLength = contentLength;
      if (etag) lastETag = etag;
      
    } catch (error) {
      // 如果 HEAD 请求失败，尝试使用 GET 请求检查文件大小
      try {
        const response = await fetch(currentFile + '?t=' + Date.now(), {
          cache: 'no-cache'
        });
        const text = await response.text();
        const currentLength = text.length;
        
        if (lastContentLength && currentLength !== lastContentLength) {
          showRefreshNotification();
          setTimeout(() => {
            window.location.reload();
          }, 500);
        } else {
          lastContentLength = currentLength;
        }
      } catch (e) {
        // 如果都失败了，使用备用方法：定期刷新
        console.warn('文件更新检查失败，将在下次检查时重试');
      }
    }
  }
  
  // 显示刷新通知
  function showRefreshNotification() {
    const notification = document.createElement('div');
    notification.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: var(--color-primary, #1890ff);
      color: white;
      padding: 12px 24px;
      border-radius: 6px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      z-index: 10000;
      font-size: 14px;
      animation: slideIn 0.3s ease-out;
    `;
    notification.textContent = '检测到文件更新，正在刷新...';
    document.body.appendChild(notification);
    
    // 添加动画
    if (!document.getElementById('refresh-animation-style')) {
      const style = document.createElement('style');
      style.id = 'refresh-animation-style';
      style.textContent = `
        @keyframes slideIn {
          from {
            transform: translateX(100%);
            opacity: 0;
          }
          to {
            transform: translateX(0);
            opacity: 1;
          }
        }
      `;
      document.head.appendChild(style);
    }
  }
  
  // 显示开发模式指示器
  function showDevIndicator() {
    const indicator = document.createElement('div');
    indicator.style.cssText = `
      position: fixed;
      bottom: 20px;
      right: 20px;
      background: rgba(0,0,0,0.7);
      color: white;
      padding: 8px 16px;
      border-radius: 6px;
      font-size: 12px;
      z-index: 9999;
      font-family: monospace;
    `;
    indicator.textContent = '🔄 实时预览模式';
    document.body.appendChild(indicator);
  }
  
  // 启动自动刷新
  if (isDevMode) {
    showDevIndicator();
    // 每 1 秒检查一次文件更新
    setInterval(checkFileUpdate, 1000);
    // 首次检查
    setTimeout(checkFileUpdate, 1000);
  }
})();

