uniform sampler2D u_atlas_tex;
uniform vec4 u_atlas_info;

varying vec4 v_glyph;

vec3 glyph_decode_f (vec4 v)
{
  ivec2 glyph_layout_ivec = ivec2 (mod (v_glyph.zw, 256));
  int glyph_layout = glyph_layout_ivec.x * 256 + glyph_layout_ivec.y;
  vec2 atlas_pos = vec2 (ivec2 (v_glyph.zw) / 256 * 4);
  return vec3 (atlas_pos, glyph_layout);
}

void main()
{
  vec2 p = v_glyph.xy;
  vec3 decoded = glyph_decode_f (v_glyph);
  vec4 atlas_pos = vec4 (decoded.xy, 0, 0);
  int glyph_layout = int (decoded.z);

  /* isotropic antialiasing */
  vec2 dpdx = dFdx (p);
  vec2 dpdy = dFdy (p);
  float m = max (length (dpdx), length (dpdy));

  float sdist = glyphy_sdf (p, u_atlas_tex, u_atlas_info, atlas_pos, glyph_layout);
  float udist = abs (sdist);

  vec4 color = vec4 (0,0,0,1);

  // Color the outline red
  color += vec4 (1,0,0,0) * smoothstep (2 * m, 0, udist);
  // Color the distance field in green
  color += vec4 (0,1,0,0) * ((1 + sin (sdist / m))) * sin (pow (udist, .8) * 3.14159265358979) * .5;
  // Color the inside of the glyph a light red
  color += vec4 (.5,0,0,0) * smoothstep (m, -m, sdist);

/*
  // Color points green
  color = mix (vec4 (0,1,0,1), color, smoothstep (2 * m, 3 * m, min_point_dist));

  // Color the number of endpoints per cell blue
  color += vec4 (0,0,1,0) * num_endpoints * 16./255.;
*/

//  color = vec4 (1,1,1,1) * smoothstep (-m, m, sdist);
  gl_FragColor = color;
}
