local dap = require 'core.dap.registry'

dap.record_dap {
  adapter = {
    name = 'python',
    cmd = 'python3',
    availability_check_args = { '-c', 'import debugpy' },
    args = { '-m', 'debugpy.adapter' },
    deps = {
      {
        cmd = 'debugpy',
        check_cmd = 'python3 -c "import debugpy"',
        install_command = 'python3 -m pip install --user --break-system-packages debugpy',
        os = {
          linux = 'python-debugpy',
          windows = 'python -m pip install debugpy',
        },
      },
    },
  },
  configurations = {
    {
      program = '${file}',
      console = 'integratedTerminal',
      justMyCode = false,
    },
  },
}
