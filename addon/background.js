/*
On startup, connect to the melpomene app.
*/
console.log("try to connect");
var port = browser.runtime.connectNative("melpomene");
console.log("connected !");

/*
Listen for messages from the app.
*/
port.onMessage.addListener((response) => {
  console.log("Received: " + JSON.stringify(response));
  // Forward status messages to popup
  if (response.status === "STATUS") {
    browser.runtime.sendMessage({type: "STATUS_UPDATE", data: response});
  }
});

function send(option, url) {
  port.postMessage(option+';'+url);
  console.log("Send " + option + " # " + url);
}

function popupDo(option) {
  page = browser.tabs.query({currentWindow: true, active: true})
  page.then((tabs) => { send(option, tabs[0].url) });
}

function checkStatus() {
  page = browser.tabs.query({currentWindow: true, active: true})
  page.then((tabs) => { send("check_status", tabs[0].url) });
}

// Listen for messages from popup
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === "CHECK_STATUS") {
    checkStatus();
  } else if (message.type === "POPUP_ACTION") {
    popupDo(message.action);
  }
});





