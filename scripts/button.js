document.getElementById("load-game-btn").addEventListener("click", function () {
  var container = document.getElementById("game-container");

  container.style.boxShadow = "none";
  container.style.backgroundImage = "none";
  container.style.borderRadius = "0px";

  container.innerHTML =
    '<iframe src="game/btd5-restored.html" frameborder="0" width="800px" height="600px" allowfullscreen allow="fullscreen"></iframe>';
});
