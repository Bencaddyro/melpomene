
var page = browser.extension.getBackgroundPage();

document.addEventListener("click", function(e) {
  if (e.target.classList.contains("item")) {
    page.popupDo(e.target.id);
  }
});
