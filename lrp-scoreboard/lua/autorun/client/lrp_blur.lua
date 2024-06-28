function LRPBlur()
    local blurMaterial = Material('pp/blurscreen')
    local blurAmount = .8
    if blurAmount > 0 then
        local tab = {
            ['$pp_colour_addr'] = 0,
            ['$pp_colour_addg'] = 0,
            ['$pp_colour_addb'] = 0,
            ['$pp_colour_mulr'] = 0,
            ['$pp_colour_mulg'] = 0,
            ['$pp_colour_mulb'] = 0,
            ['$pp_colour_brightness'] = -blurAmount * .2,
            ['$pp_colour_contrast'] = 1 + .5 * blurAmount,
            ['$pp_colour_colour'] = 1 - blurAmount,
        }

        DrawColorModify(tab)
        surface.SetDrawColor(255, 255, 255, blurAmount * 255)
        surface.SetMaterial(blurMaterial)
        for i = 1, 3 do 
            blurMaterial:SetFloat('$blur', blurAmount * i * 2)
            blurMaterial:Recompute() 
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(-1, -1, ScrW() + 2, ScrH() + 2)
        end
        
        draw.NoTexture()
        surface.SetDrawColor(0, 45, 35, blurAmount * 250)
        surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
    end
end