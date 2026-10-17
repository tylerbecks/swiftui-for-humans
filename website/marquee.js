// The hero marquee: two rows of component tiles that scroll forever.
// Each row's tiles are repeated once so the track can slide by exactly half
// its width and start over without a seam.
//
// Animated tiles hold a 6-second video of the real component, made by
// scripts/hero-reel.sh: at rest at 0 s, changed by 3 s, back at rest by 6 s.
// Every so often one tile on screen, picked at random, plays half of it, so
// the strip feels alive without everything moving at once.
(() => {
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)');
  const dark = matchMedia('(prefers-color-scheme: dark)');
  const marquee = document.querySelector('.marquee');
  if (!marquee || reduceMotion.matches) return; // Stay a still, swipeable strip.

  for (const track of marquee.querySelectorAll('.marquee-track')) {
    for (const tile of [...track.children]) {
      const copy = tile.cloneNode(true);
      copy.setAttribute('aria-hidden', 'true');
      track.append(copy);
    }
  }

  const HALF = 3; // Seconds from one resting frame to the next.
  const videoSource = (tile) => `/images/hero/${tile.dataset.tile}-${dark.matches ? 'dark' : 'light'}.mp4`;

  const videos = [];
  for (const tile of marquee.querySelectorAll('.tile[data-video]')) {
    const video = document.createElement('video');
    const alwaysMoving = tile.dataset.tile === 'spinner';
    Object.assign(video, { muted: true, playsInline: true, loop: alwaysMoving, preload: 'auto' });
    video.setAttribute('muted', '');
    video.setAttribute('aria-hidden', 'true');
    video.src = videoSource(tile);
    // Show the video over the still once its first frame is ready; they match.
    video.addEventListener('loadeddata', () => video.classList.add('ready'));
    tile.append(video);
    if (alwaysMoving) video.dataset.always = '';
    else videos.push(video);
  }

  // Only tiles fully inside the window take a turn.
  const isVisible = (el) => {
    const r = el.getBoundingClientRect();
    return r.left >= 0 && r.right <= innerWidth && r.bottom > 0 && r.top < innerHeight;
  };

  // Play from one resting frame to the next, then stop there.
  const playOnce = (video) => {
    const from = video.currentTime < HALF / 2 ? 0 : HALF;
    video.currentTime = from;
    video.dataset.playing = '';
    video.play().catch(() => {});
    setTimeout(() => {
      video.pause();
      video.currentTime = from === 0 ? HALF : 0;
      delete video.dataset.playing;
    }, HALF * 1000);
  };

  let running = false;
  const tick = () => {
    if (!running) return;
    const choices = videos.filter((v) => v.classList.contains('ready') && !('playing' in v.dataset) && isVisible(v));
    if (choices.length) playOnce(choices[Math.floor(Math.random() * choices.length)]);
    setTimeout(tick, 900 + Math.random() * 1600);
  };

  // Pause everything while the strip is off screen or the tab is hidden.
  const setRunning = (on) => {
    if (on === running) return;
    running = on;
    for (const video of marquee.querySelectorAll('video[data-always]')) {
      if (on) video.play().catch(() => {});
      else video.pause();
    }
    if (on) setTimeout(tick, 600);
  };
  let onScreen = false;
  new IntersectionObserver(([entry]) => {
    onScreen = entry.isIntersecting;
    setRunning(onScreen && !document.hidden);
  }).observe(marquee);
  document.addEventListener('visibilitychange', () => setRunning(onScreen && !document.hidden));

  dark.addEventListener('change', () => {
    for (const video of marquee.querySelectorAll('video')) {
      video.classList.remove('ready');
      video.src = videoSource(video.parentElement);
      if ('always' in video.dataset && running) video.play().catch(() => {});
    }
  });

  marquee.classList.add('is-moving');
})();
