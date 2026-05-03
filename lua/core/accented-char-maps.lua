local M = {}

function M.setup()
    local instant_maps = {
        [",nn"] = "ñ",
        [",aa"] = "á",
        [",cc"] = "ç",
        [",ee"] = "é",
        [",ii"] = "í",
        [",oo"] = "ó",
        [":uu"] = "ü",
        [":oo"] = "ö",
        [";oo"] = "ő",
        [";uu"] = "ű",
        [",uu"] = "ú",
        [",NN"] = "Ñ",
        [",AA"] = "Á",
        [",CC"] = "Ç",
        [",EE"] = "É",
        [",II"] = "Í",
        [",OO"] = "Ó",
        [":UU"] = "Ü",
        [":OO"] = "Ö",
        [";OO"] = "Ő",
        [";UU"] = "Ű",
        [",UU"] = "Ú",
        ["!!!"] = "¡!<Left>",
        ["???"] = "¿?<Left>",
    }

    for key, val in pairs(instant_maps) do
        -- buffer = true is the KEY here. 
        -- It makes the map local to the current file only.
        vim.keymap.set("i", key, val, { noremap = true, silent = true, buffer = true })
    end
end

return M
