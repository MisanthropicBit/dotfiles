-- require("config.c-like-after")

vim.b.run = {
    "ninja",
    "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 . -G Ninja",
}

vim.o.makeprg = "ninja"
