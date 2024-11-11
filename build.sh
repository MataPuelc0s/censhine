export LUA_PATH='./?.lua;./src/lua/lua_modules/?.lua;./src/lua/lua_modules/fs/?.lua;./src/lua/lua_modules/?/init.lua'
export SHADER_PATH='./src/game/rasterizer/dx9/shaders'
export SHADER_COMPILE_CMD="luajit src/lua/compile.lua $SHADER_PATH"
set -e

################################################################################
## Compile the pixel shaders
################################################################################

# General shaders
#$SHADER_COMPILE_CMD/pixel/general/active_camouflage_draw.fx --s30
$SHADER_COMPILE_CMD/pixel/general/widget_sprite.fx
$SHADER_COMPILE_CMD/pixel/general/shadow_convolve.fx

# Transparent water
$SHADER_COMPILE_CMD/pixel/transparent_water/transparent_water_opacity.fx
$SHADER_COMPILE_CMD/pixel/transparent_water/transparent_water_reflection.fx
$SHADER_COMPILE_CMD/pixel/transparent_water/transparent_water_bumpmap_convolution.fx

# Transparent glass
#$SHADER_COMPILE_CMD/pixel/transparent_glass/transparent_glass_diffuse.fx
#$SHADER_COMPILE_CMD/pixel/transparent_glass/transparent_glass_tint.fx
$SHADER_COMPILE_CMD/pixel/transparent_glass/transparent_glass_reflection_bumped.fx
#$SHADER_COMPILE_CMD/pixel/transparent_glass/transparent_glass_reflection_flat.fx
#$SHADER_COMPILE_CMD/pixel/transparent_glass/transparent_glass_reflection_mirror.fx

# Transparent plasma
$SHADER_COMPILE_CMD/pixel/transparent_plasma/transparent_plasma.fx

# Transparent generic
#$SHADER_COMPILE_CMD/pixel/transparent_generic/transparent_generic.fx
#$SHADER_COMPILE_CMD/pixel/transparent_generic_shader/transparent_generic_shader.psh --disable

# Models
$SHADER_COMPILE_CMD/pixel/model/model_environment.fx
#$SHADER_COMPILE_CMD/pixel/model/model_mask_change_color.fx
#$SHADER_COMPILE_CMD/pixel/model/model_mask_multipurpose.fx
#$SHADER_COMPILE_CMD/pixel/model/model_mask_none.fx
#$SHADER_COMPILE_CMD/pixel/model/model_mask_reflection.fx
#$SHADER_COMPILE_CMD/pixel/model/model_mask_self_illumination.fx

# Environment fog
$SHADER_COMPILE_CMD/pixel/environment/environment_fog.fx

# Environment reflection
$SHADER_COMPILE_CMD/pixel/environment_reflection/environment_reflection_bumped.fx
$SHADER_COMPILE_CMD/pixel/environment_reflection/environment_reflection_flat.fx
$SHADER_COMPILE_CMD/pixel/environment_reflection/environment_reflection_flat_specular.fx
$SHADER_COMPILE_CMD/pixel/environment_reflection/environment_reflection_lightmap_mask.fx
#$SHADER_COMPILE_CMD/pixel/environment_reflection/environment_reflection_mirror_bumped.fx --disable
$SHADER_COMPILE_CMD/pixel/environment_reflection/environment_reflection_radiosity.fx

# Environment lightmap
$SHADER_COMPILE_CMD/pixel/environment_lightmap/environment_lightmap_normal.fx
$SHADER_COMPILE_CMD/pixel/environment_lightmap/environment_lightmap_no_illumination.fx --compatible
$SHADER_COMPILE_CMD/pixel/environment_lightmap/environment_lightmap_no_illumination_no_lightmap.fx
$SHADER_COMPILE_CMD/pixel/environment_lightmap/environment_lightmap_no_lightmap.fx

# Environment diffuse
$SHADER_COMPILE_CMD/pixel/environment/environment_diffuse_lights.fx

# Enviroment specular
$SHADER_COMPILE_CMD/pixel/environment_specular/environment_specular_light_bumped.fx
$SHADER_COMPILE_CMD/pixel/environment_specular/environment_specular_light_flat.fx
$SHADER_COMPILE_CMD/pixel/environment_specular/environment_specular_lightmap_bumped.fx
$SHADER_COMPILE_CMD/pixel/environment_specular/environment_specular_lightmap_flat.fx

# Environment texture
## Blended
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_biased_add_biased_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_biased_add_biased_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_biased_add_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_biased_multiply_biased_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_biased_multiply_biased_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_biased_multiply_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_multiply_biased_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_multiply_biased_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_blended_multiply_multiply.fx --disable

## Normal
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_biased_add_biased_add.fx
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_biased_add_biased_multiply.fx
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_biased_add_multiply.fx
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_biased_multiply_biased_add.fx
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_biased_multiply_biased_multiply.fx
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_biased_multiply_multiply.fx
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_multiply_biased_add.fx
$SHADER_COMPILE_CMD/pixel/environment_texture/normal/environment_texture_normal_multiply_multiply.fx

## Specular
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_biased_add_biased_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_biased_add_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_biased_multiply_biased_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_biased_multiply_biased_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_biased_multiply_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_multiply_biased_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_multiply_biased_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/environment_texture_specular_mask_multiply_multiply.fx --disable

#$SHADER_COMPILE_CMD/pixel/effect_multitexture_nonlinear_tint.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_nonlinear_tint_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_nonlinear_tint_alpha_blend.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_nonlinear_tint_double_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_nonlinear_tint_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_nonlinear_tint_multiply_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_normal_tint.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_normal_tint_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_normal_tint_alpha_blend.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_normal_tint_double_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_normal_tint_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_multitexture_normal_tint_multiply_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_nonlinear_tint.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_nonlinear_tint_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_nonlinear_tint_alpha_blend.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_nonlinear_tint_double_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_nonlinear_tint_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_nonlinear_tint_multiply_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_normal_tint.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_normal_tint_add.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_normal_tint_alpha_blend.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_normal_tint_double_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_normal_tint_multiply.fx --disable
#$SHADER_COMPILE_CMD/pixel/effect_normal_tint_multiply_add.fx --disable

$SHADER_COMPILE_CMD/vertex/transparent_water/transparent_water_opacity.vsh --vertex
$SHADER_COMPILE_CMD/vertex/transparent_water/transparent_water_opacity_m.vsh --vertex
$SHADER_COMPILE_CMD/vertex/transparent_water/transparent_water_reflection.vsh --vertex
$SHADER_COMPILE_CMD/vertex/transparent_water/transparent_water_reflection_m.vsh --vertex

$SHADER_COMPILE_CMD/vertex/model_fogged/model_fogged.vsh --vertex
$SHADER_COMPILE_CMD/vertex/model_fog_screen/model_fog_screen.vsh --vertex
$SHADER_COMPILE_CMD/vertex/model_scenery/model_scenery.vsh --vertex
$SHADER_COMPILE_CMD/vertex/environment_fog/environment_fog.vsh --vertex
$SHADER_COMPILE_CMD/vertex/environment_fog_screen/environment_fog_screen.vsh --vertex

################################################################################
## Build shaders
################################################################################

luajit src/lua/build.lua build/EffectCollection_ps_2_0 --encrypt
luajit src/lua/build.lua build/vsh --vertex --encrypt
