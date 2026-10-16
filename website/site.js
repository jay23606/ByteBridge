// Adds a Copy button to every command block. The page works the same
// without it; this only saves selecting the text by hand.
(function () {
  if (!navigator.clipboard) return;

  var arabic = document.documentElement.lang === "ar";
  var label = arabic ? "نسخ" : "Copy";
  var done = arabic ? "نُسخ" : "Copied";

  document.querySelectorAll(".code").forEach(function (block) {
    var pre = block.querySelector("pre");
    if (!pre) return;

    var button = document.createElement("button");
    button.type = "button";
    button.className = "copy";
    button.textContent = label;
    button.addEventListener("click", function () {
      navigator.clipboard.writeText(pre.innerText.replace(/\n$/, "")).then(function () {
        button.textContent = done;
        setTimeout(function () { button.textContent = label; }, 1500);
      });
    });
    block.appendChild(button);
    block.classList.add("has-copy");
  });
})();
