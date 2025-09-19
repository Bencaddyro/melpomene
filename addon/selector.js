
// Update status display
function updateStatus(statusData) {
  var statusElement = document.getElementById("status");
  if (statusData.error) {
    statusElement.textContent = "❌ " + statusData.error;
  } else {
    var icon = "📁";
    if (statusData.in_audio && statusData.in_clip) {
      icon = "🎬🎶";
    } else if (statusData.in_audio) {
      icon = "🎶";
    } else if (statusData.in_clip) {
      icon = "🎬";
    } else {
      icon = "✨";
    }
    statusElement.textContent = icon + " " + statusData.status;
  }
}

// Listen for messages from background script
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === "STATUS_UPDATE") {
    updateStatus(message.data.data);
  }
});

// Request status when popup opens
browser.runtime.sendMessage({type: "CHECK_STATUS"});

// Handle button clicks
document.addEventListener("click", function(e) {
  if (e.target.classList.contains("item")) {
    browser.runtime.sendMessage({type: "POPUP_ACTION", action: e.target.id});
  }
});
