// The showcase clips: recordings of the real app, in light or dark to match
// the visitor. Each plays only while on screen, and stays a still (its
// poster) for people who prefer reduced motion.
(() => {
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const dark = matchMedia('(prefers-color-scheme: dark)');
  const videos = [...document.querySelectorAll('video[data-clip]')];
  const load = () => {
    const mode = dark.matches ? 'dark' : 'light';
    for (const video of videos) {
      const clip = video.dataset.clip;
      video.poster = `/images/showcase/${clip}-${mode}.jpg`;
      if (!reduceMotion) video.src = `/images/showcase/${clip}-${mode}.mp4`;
    }
  };
  load();
  dark.addEventListener('change', load);
  if (reduceMotion) return;
  const observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) entry.target.play().catch(() => {});
      else entry.target.pause();
    }
  }, { threshold: 0.4 });
  videos.forEach((video) => observer.observe(video));
})();
