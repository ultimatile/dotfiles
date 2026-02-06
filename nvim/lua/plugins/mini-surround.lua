return {
  "nvim-mini/mini.surround",
  opts = {
    custom_surroundings = {
      -- function with curly braces
      g = {
        input = { "%f[%w_%.][%w_%.]+%b{}", "^.-{().*()}$" },
        output = function()
          local fun_name = require("mini.surround").user_input("Function name")
          if fun_name == nil then
            return nil
          end
          return { left = ("%s{"):format(fun_name), right = "}" }
        end,
      },
    },
  },
}
