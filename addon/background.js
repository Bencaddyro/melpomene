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
  console.log("Received: " + response);
});

function send(option, url) {
  port.postMessage(option+';'+url);
  console.log("Send " + option + " # " + url);
}

function popupDo(option) {
  page = browser.tabs.query({currentWindow: true, active: true})
  page.then((tabs) => { send(option, tabs[0].url) });
}





