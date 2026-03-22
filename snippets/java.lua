local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require('luasnip.extras').rep

return {
  s('crud', {
    t { '@RestController', '@RequestMapping(<route>' },
    i(1, 'users'),
    t { ')', 'public class ' },
    i(2, '<entityname>Controller'),
  }),
}
