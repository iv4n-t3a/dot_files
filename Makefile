.PHONY: stow unstow restow help

STOW := stow
STOW_DIR := .
TARGET := $(HOME)
PKGS := alacritty dunst flameshot moc nvim rofi sway vifm waybar zsh

stow:
	$(STOW) -v -t $(TARGET) -d $(STOW_DIR) $(PKGS)

unstow:
	$(STOW) -v -t $(TARGET) -d $(STOW_DIR) -D $(PKGS)

restow: unstow stow

dry-run:
	$(STOW) -nv -t $(TARGET) -d $(STOW_DIR) $(PKGS)

status:
	@echo "Packages to stow:"
	@for pkg in $(PKGS); do \
		echo "  - $$pkg"; \
	done

help:
	@echo "Usage:"
	@echo "  make stow      - Stow all packages to home directory"
	@echo "  make unstow    - Unstow all packages"
	@echo "  make restow    - Unstow then stow (refresh)"
	@echo "  make dry-run   - Preview what would be stowed"
	@echo "  make status    - List packages to be stowed"
