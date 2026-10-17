// The hero backdrop: a masonry board of real component tiles behind the
// title. Columns drift slowly, alternating up and down, and loop without a
// seam because each column holds its tiles twice and slides by half.
//
// Tiles come from scripts/hero-reel.sh, which also writes the list
// (images/hero/tiles.js). Every tile starts as a still. Animated tiles have
// a 6-second video of the real component, at rest at 0 s and again at 3 s.
// Every so often one tile, picked at random and not behind the text, loads
// its video, plays one change, swaps to the still of where it stopped, and
// drops the video, so only one or two videos exist at a time.
(() => {
  const board = document.querySelector('.board');
  const tiles = window.heroTiles;
  if (!board || !tiles) return;
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const dark = matchMedia('(prefers-color-scheme: dark)');
  const theme = () => (dark.matches ? 'dark' : 'light');
  const HALF = 3; // Seconds from one resting frame to the next.
  const still = (el, state) =>
    `/images/hero/${el.dataset.tile}-${theme()}${state === 'b' ? '-b' : ''}.webp`;

  const makeTile = (tile) => {
    const el = document.createElement('div');
    el.className = 'board-tile';
    el.dataset.tile = tile.name;
    el.dataset.title = tile.title;
    if (tile.animated) el.dataset.animated = '';
    el.style.aspectRatio = `240 / ${tile.height}`;
    const img = document.createElement('img');
    img.alt = '';
    img.decoding = 'async';
    img.src = still(el, 'a');
    el.append(img);
    return el;
  };

  // Enough columns to cover the hero, each starting at a different tile so
  // neighbors don't match. Columns hold tiles until they're a bit taller than
  // the hero, then repeat them once for the loop.
  const build = () => {
    board.replaceChildren();
    const style = getComputedStyle(board);
    const columnWidth = parseFloat(style.getPropertyValue('--column'));
    const gap = parseFloat(style.getPropertyValue('--gap'));
    const count = Math.ceil(board.clientWidth / (columnWidth + gap)) + 1;
    let next = 0;
    for (let c = 0; c < count; c++) {
      const column = document.createElement('div');
      column.className = 'board-column';
      column.style.setProperty('--duration', `${90 + ((c * 37) % 50)}s`);
      column.style.setProperty('--offset', `${-((c * 53) % 160)}px`);
      if (c % 2) column.dataset.down = '';
      const set = [];
      let filled = 0;
      while (filled < board.clientHeight * 1.2 || set.length < 3) {
        const tile = tiles[next++ % tiles.length];
        set.push(tile);
        filled += (columnWidth * tile.height) / 240 + gap;
      }
      for (const tile of [...set, ...set]) column.append(makeTile(tile));
      board.append(column);
    }
    board.classList.toggle('is-moving', !reduceMotion);
  };

  // Only tiles fully on screen and clear of the text take a turn.
  const content = document.querySelector('.hero-board .hero');
  const textBounds = () => {
    const rects = [...content.children].map((child) => child.getBoundingClientRect());
    return {
      top: Math.min(...rects.map((r) => r.top)),
      bottom: Math.max(...rects.map((r) => r.bottom)),
      left: Math.min(...rects.map((r) => r.left)),
      right: Math.max(...rects.map((r) => r.right)),
    };
  };
  const canPlay = (el) => {
    const r = el.getBoundingClientRect();
    const b = board.parentElement.getBoundingClientRect();
    const t = textBounds();
    const onBoard = r.top >= b.top && r.bottom <= b.bottom && r.left >= 0 && r.right <= innerWidth;
    const behindText = r.right > t.left + 40 && r.left < t.right - 40 && r.bottom > t.top && r.top < t.bottom;
    return onBoard && !behindText;
  };

  // Load the video, play one change from the resting frame the tile shows,
  // then show the still of the other resting frame and drop the video.
  const playOnce = (el) => {
    const from = el.dataset.state === 'b' ? HALF : 0;
    const to = from ? 'a' : 'b';
    const video = document.createElement('video');
    Object.assign(video, { muted: true, playsInline: true, preload: 'auto' });
    video.setAttribute('muted', '');
    video.src = `/images/hero/${el.dataset.tile}-${theme()}.mp4`;
    el.dataset.playing = '';
    const done = () => {
      el.classList.remove('is-active');
      video.remove();
      delete el.dataset.playing;
    };
    // iOS only loads a video once it's asked to play, so start it hidden,
    // jump to the resting frame, and show it once it's playing from there.
    video.addEventListener('loadedmetadata', () => { if (from) video.currentTime = from; }, { once: true });
    const reveal = () => {
      if (video.currentTime < from || video.currentTime > from + 1) return;
      video.removeEventListener('timeupdate', reveal);
      video.classList.add('ready');
      el.classList.add('is-active');
      // Have the next still decoded before swapping, so nothing flashes.
      const next = new Image();
      next.src = still(el, to);
      setTimeout(async () => {
        video.pause();
        await next.decode().catch(() => {});
        el.querySelector('img').src = next.src;
        el.dataset.state = to;
        done();
      }, (from + HALF - video.currentTime) * 1000);
    };
    video.addEventListener('timeupdate', reveal);
    video.addEventListener('error', done, { once: true });
    el.append(video);
    video.play().catch(done);
  };

  let running = false;
  const tick = () => {
    if (!running) return;
    const choices = [...board.querySelectorAll('.board-tile[data-animated]:not([data-playing])')].filter(canPlay);
    if (choices.length) playOnce(choices[Math.floor(Math.random() * choices.length)]);
    setTimeout(tick, 700 + Math.random() * 1500);
  };

  const setRunning = (on) => {
    if (reduceMotion || on === running) return;
    running = on;
    board.classList.toggle('is-paused', !on);
    if (on) setTimeout(tick, 500);
  };

  // A little depth: the board leans away from the cursor.
  if (!reduceMotion && matchMedia('(hover: hover) and (pointer: fine)').matches) {
    const hero = board.parentElement;
    let x = 0, y = 0, tx = 0, ty = 0, frame = 0;
    const step = () => {
      x += (tx - x) * 0.08;
      y += (ty - y) * 0.08;
      board.style.setProperty('--px', `${x.toFixed(2)}px`);
      board.style.setProperty('--py', `${y.toFixed(2)}px`);
      frame = Math.abs(tx - x) + Math.abs(ty - y) > 0.1 ? requestAnimationFrame(step) : 0;
    };
    hero.addEventListener('pointermove', (event) => {
      const r = hero.getBoundingClientRect();
      tx = -((event.clientX - r.left) / r.width - 0.5) * 24;
      ty = -((event.clientY - r.top) / r.height - 0.5) * 16;
      if (!frame) frame = requestAnimationFrame(step);
    });
    hero.addEventListener('pointerleave', () => {
      tx = ty = 0;
      if (!frame) frame = requestAnimationFrame(step);
    });
  }

  build();
  let onScreen = true;
  new IntersectionObserver(([entry]) => {
    onScreen = entry.isIntersecting;
    setRunning(onScreen && !document.hidden);
  }).observe(board);
  document.addEventListener('visibilitychange', () => setRunning(onScreen && !document.hidden));

  // Rebuild when the column count would change, or the theme does.
  const rebuild = () => {
    running = false;
    build();
    setRunning(onScreen && !document.hidden);
  };
  let lastWidth = innerWidth;
  addEventListener('resize', () => {
    if (Math.abs(innerWidth - lastWidth) < 120) return;
    lastWidth = innerWidth;
    rebuild();
  });
  dark.addEventListener('change', rebuild);
})();
