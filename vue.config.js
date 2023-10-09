const { defineConfig } = require("@vue/cli-service");
module.exports = defineConfig({
  publicPath: '/test/', 
  transpileDependencies: true,
});

module.exports = {
  devServer: {
    port: 5000
  }
};