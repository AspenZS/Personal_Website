(() => {
  const toggle = document.querySelector('.nav-toggle');
  const navigation = document.querySelector('.nav-links');

  if (toggle && navigation) {
    const closeMenu = ({ returnFocus = false } = {}) => {
      navigation.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
      if (returnFocus) toggle.focus();
    };

    toggle.addEventListener('click', () => {
      const isOpen = navigation.classList.toggle('open');
      toggle.setAttribute('aria-expanded', String(isOpen));
    });

    navigation.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => closeMenu());
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && navigation.classList.contains('open')) {
        closeMenu({ returnFocus: true });
      }
    });

    document.addEventListener('click', (event) => {
      if (
        navigation.classList.contains('open') &&
        !navigation.contains(event.target) &&
        !toggle.contains(event.target)
      ) {
        closeMenu();
      }
    });

    window.addEventListener('resize', () => {
      if (window.innerWidth > 760) closeMenu();
    });
  }

  const year = document.getElementById('year');
  if (year) year.textContent = String(new Date().getFullYear());
})();
