return {
  cmd = { 'jdtls' },
  filetypes = { 'java' },
  root_markers = { 'gradlew', 'settings.gradle', 'pom.xml', '.git' },
  settings = {
    java = {
      configuration = {
        runtimes = {
          { name = 'JavaSE-21', path = '/usr/lib/jvm/java-21-openjdk' },
        },
      },
    },
  },
}
