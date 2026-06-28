// Static require() map for the AI-generated art (Metro needs literal requires).
export const IMG: Record<string, any> = {
  // characters
  char_pharaoh: require('../../assets/game/char_pharaoh.png'),
  char_builder: require('../../assets/game/char_builder.png'),
  char_scribe: require('../../assets/game/char_scribe.png'),
  char_nubian: require('../../assets/game/char_nubian.png'),
  char_priest: require('../../assets/game/char_priest.png'),
  char_warrior: require('../../assets/game/char_warrior.png'),
  char_royal: require('../../assets/game/char_royal.png'),
  char_queen: require('../../assets/game/char_queen.png'),
  char_farmer: require('../../assets/game/char_farmer.png'),
  char_merchant: require('../../assets/game/char_merchant.png'),
  char_dancer: require('../../assets/game/char_dancer.png'),
  char_archer: require('../../assets/game/char_archer.png'),
  char_mummy: require('../../assets/game/char_mummy.png'),
  char_anubis: require('../../assets/game/char_anubis.png'),
  char_horus: require('../../assets/game/char_horus.png'),
  char_ra: require('../../assets/game/char_ra.png'),
  char_footballer: require('../../assets/game/char_footballer.png'),
  char_comedian: require('../../assets/game/char_comedian.png'),
  char_diva: require('../../assets/game/char_diva.png'),
  char_star: require('../../assets/game/char_star.png'),
  // wonders (3D structures)
  s_great: require('../../assets/game/s_great.png'),
  s_djoser: require('../../assets/game/s_djoser.png'),
  s_red: require('../../assets/game/s_red.png'),
  s_obelisk: require('../../assets/game/s_obelisk.png'),
  s_pylon: require('../../assets/game/s_pylon.png'),
  s_ziggurat: require('../../assets/game/s_ziggurat.png'),
  s_giza: require('../../assets/game/s_giza.png'),
  s_grand: require('../../assets/game/s_grand.png'),
  // scenes
  bg_giza: require('../../assets/game/bg_giza.png'),
  bg_giza_sunset: require('../../assets/game/bg_giza_sunset.png'),
  bg_giza_night: require('../../assets/game/bg_giza_night.png'),
  bg_temple: require('../../assets/game/bg_temple.png'),
  bg_nile: require('../../assets/game/bg_nile.png'),
  // props
  p_worker: require('../../assets/game/p_worker.png'),
  p_capstone: require('../../assets/game/p_capstone.png'),
  // ui icons (tintable silhouettes)
  ic_home: require('../../assets/game/ic_home.png'),
  ic_stats: require('../../assets/game/ic_stats.png'),
  ic_shop: require('../../assets/game/ic_shop.png'),
  ic_settings: require('../../assets/game/ic_settings.png'),
  ic_crown: require('../../assets/game/ic_crown.png'),
  ic_flame: require('../../assets/game/ic_flame.png'),
  ic_trophy: require('../../assets/game/ic_trophy.png'),
  ic_moon: require('../../assets/game/ic_moon.png'),
};

export function img(name: string) {
  return IMG[name];
}

// baked-in pixel dimensions (cross-platform aspect ratios; web has no resolveAssetSource)
export const DIM: Record<string, [number, number]> = {
  bg_giza: [1024, 1024], bg_giza_sunset: [420, 234], bg_giza_night: [420, 234], bg_nile: [420, 178], bg_temple: [420, 229],
  s_great: [420, 319], s_djoser: [420, 317], s_red: [420, 407], s_obelisk: [198, 420], s_pylon: [420, 354], s_ziggurat: [420, 319], s_giza: [420, 257], s_grand: [417, 420],
  p_worker: [420, 328], p_capstone: [420, 404],
  char_pharaoh: [235, 420], char_builder: [205, 420], char_scribe: [217, 420], char_nubian: [187, 420], char_priest: [272, 420], char_warrior: [181, 420], char_royal: [253, 420], char_queen: [198, 420], char_farmer: [256, 420], char_merchant: [181, 420], char_dancer: [187, 420], char_archer: [247, 420], char_mummy: [190, 420], char_anubis: [215, 420], char_horus: [199, 420], char_ra: [185, 420], char_footballer: [195, 420], char_comedian: [195, 420], char_diva: [244, 420], char_star: [176, 420],
};

export function aspect(name: string): number {
  const d = DIM[name];
  return d ? d[0] / d[1] : 1;
}
