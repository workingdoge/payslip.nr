start_sandbox:
  @if ! colima status 2>&1 | grep -q "running"; then \
    echo "Starting Colima..."; \
    colima start; \
  fi
  cd ~/.aztec && docker compose up

update_sandbox:
  /bin/bash -c "$(curl -fsSL 'https://sandbox.aztec.network')"
