function fsElement() {
  return (
    document.fullscreenElement ||
    document.webkitFullscreenElement ||
    document.msFullscreenElement ||
    null
  );
}

function onChange() {
  const fs = fsElement();
  if (fs && fs.tagName === "IFRAME") document.documentElement.classList.add("game-fullscreen");
  else document.documentElement.classList.remove("game-fullscreen");
}

document.addEventListener("fullscreenchange", onChange);
document.addEventListener("webkitfullscreenchange", onChange);
window.addEventListener("load", onChange);
