extends Node
# Localization for Tarkeez. Arabic / English with a shared Cairo font that
# carries Latin + Arabic glyphs (so one font draws both). Autoloaded as `Loc`.

var font: Font                      # main font (Cairo if available, else fallback)
var has_arabic := false

# key -> [en, ar]
const STR := {
	"app_name": ["Tarkeez", "تركيز"],
	"tagline": ["focus & grow", "ركّز وازدهر"],
	"start": ["Start Focus", "ابدأ التركيز"],
	"give_up": ["Give Up", "استسلام"],
	"focusing": ["focusing…", "جارٍ التركيز…"],
	"pick_len": ["Choose a focus length", "اختر مدة التركيز"],
	"stay": ["Stay in the app to grow your oasis.", "ابقَ في التطبيق لتنمو واحتك."],
	"left_app": ["You left — focus broken! Stay next time.", "غادرت — انكسر التركيز! ابقَ في المرة القادمة."],
	"gave_up": ["Session ended. No growth — try again!", "انتهت الجلسة. لا نمو — حاول مجددًا!"],
	"done": ["Mashallah! +%d drops. Your oasis grew.", "ما شاء الله! +%d قطرة. نمت واحتك."],
	"keep_focus": ["Stay focused. Don't leave the app!", "ابقَ مركزًا. لا تغادر التطبيق!"],
	"today": ["Today", "اليوم"],
	"total": ["Total", "الإجمالي"],
	"sessions": ["Sessions", "الجلسات"],
	"streak": ["Streak", "السلسلة"],
	"best": ["Best", "الأفضل"],
	"drops": ["Drops", "القطرات"],
	"custom": ["Custom", "مخصص"],
	"pomodoro": ["Pomodoro", "بومودورو"],
	"break_time": ["Break — relax a little.", "استراحة — استرخِ قليلًا."],
	"break_over": ["Break over. Ready to focus?", "انتهت الاستراحة. جاهز للتركيز؟"],
	# nav
	"nav_home": ["Home", "الرئيسية"],
	"nav_stats": ["Stats", "إحصائيات"],
	"nav_shop": ["Style", "تنميق"],
	"wardrobe": ["Wardrobe", "خزانة الملابس"],
	"characters": ["Characters", "الشخصيات"],
	"scenes": ["Scenes", "المشاهد"],
	"slot_head": ["Hat", "غطاء الرأس"],
	"slot_cloth": ["Cloak", "العباءة"],
	"slot_hand": ["Hand", "اليد"],
	"slot_feet": ["Feet", "القدم"],
	"nav_settings": ["Settings", "الإعدادات"],
	# stats
	"this_week": ["Last 5 weeks", "آخر ٥ أسابيع"],
	"total_focus": ["Total focus", "إجمالي التركيز"],
	"best_streak": ["Best streak", "أطول سلسلة"],
	"day_goal": ["Daily goal", "الهدف اليومي"],
	"goal_met": ["Goal reached today! 🌿", "تحقق هدف اليوم! 🌿"],
	"stage": ["Stage", "المرحلة"],
	"stones": ["stones", "حجر"],
	"wonder": ["Wonder", "أثر"],
	"to_next": ["%d sessions to next stage", "%d جلسات للمرحلة التالية"],
	"maxed": ["Grand oasis — fully grown!", "الواحة الكبرى — اكتمل النمو!"],
	# shop
	"camel_skins": ["Camel Skins", "أزياء الجمل"],
	"oasis_themes": ["Oasis Themes", "ثيمات الواحة"],
	"owned": ["Owned", "مملوك"],
	"equipped": ["Equipped", "مُجهَّز"],
	"equip": ["Equip", "تجهيز"],
	"buy": ["Buy", "شراء"],
	"plus_only": ["Tarkeez+", "تركيز+"],
	"need_more": ["Not enough drops", "قطرات غير كافية"],
	# settings
	"sound": ["Sound", "الصوت"],
	"language": ["Language", "اللغة"],
	"on": ["On", "تشغيل"],
	"off": ["Off", "إيقاف"],
	"english": ["English", "الإنجليزية"],
	"arabic": ["العربية", "العربية"],
	"reset": ["Reset progress", "إعادة ضبط التقدم"],
	"reset_confirm": ["Tap again to confirm reset", "اضغط مرة أخرى للتأكيد"],
	"about": ["Tarkeez — grow an oasis by focusing.", "تركيز — ازرع واحة بالتركيز."],
	"version": ["Version", "الإصدار"],
	# onboarding
	"welcome": ["Welcome to Tarkeez", "مرحبًا بك في تركيز"],
	"ob_intro": ["Focus to grow a camel and a desert oasis. Leave the app mid-session and growth stops.",
		"ركّز لتنمّي جملًا وواحة صحراوية. غادر أثناء الجلسة فيتوقف النمو."],
	"name_camel": ["Name your camel", "سمِّ جملك"],
	"set_goal": ["Daily focus goal", "هدف التركيز اليومي"],
	"lets_go": ["Begin", "ابدأ"],
	"next": ["Next", "التالي"],
	"min_short": ["min", "د"],
	"hr_short": ["h", "س"],
	# celebration / plus / achievements / modes
	"grew_title": ["A wonder is complete! 🏛️", "اكتمل أثر عظيم! 🏛️"],
	"now_building": ["Now building", "نبني الآن"],
	"continue": ["Continue", "متابعة"],
	"plus_title": ["Tarkeez+", "تركيز+"],
	"plus_tag": ["Grow faster. Unlock more.", "انمُ أسرع. افتح المزيد."],
	"plus_b1": ["Premium camel skins & oasis themes", "أزياء جمل وثيمات واحة مميزة"],
	"plus_b2": ["Detailed insights & achievements", "إحصاءات وإنجازات مفصلة"],
	"plus_b3": ["Custom soundscapes & cloud sync", "أصوات مخصصة ومزامنة سحابية"],
	"plus_price": ["$3.99 / month", "٣٫٩٩$ / شهر"],
	"subscribe": ["Start Tarkeez+", "ابدأ تركيز+"],
	"restore": ["Restore", "استعادة"],
	"maybe_later": ["Maybe later", "لاحقًا"],
	"plus_active": ["Tarkeez+ active ✦", "تركيز+ مفعّل ✦"],
	"achievements": ["Achievements", "الإنجازات"],
	"locked": ["Locked", "مقفل"],
	"notifications": ["Notifications", "الإشعارات"],
	"haptics": ["Haptics", "الاهتزاز"],
	"ramadan_mode": ["Ramadan mode", "وضع رمضان"],
	"ramadan_greet": ["Ramadan Kareem 🌙", "رمضان كريم 🌙"],
}

# calm motivational quotes for session completion
const QUOTES := [
	["Stone by stone, a wonder rises.", "حجرًا حجرًا، يرتفع الأثر."],
	["Focus is a quiet kind of strength.", "التركيز قوة هادئة."],
	["One stone at a time.", "حجر واحد في كل مرة."],
	["Patience builds pyramids.", "الصبر يبني الأهرام."],
	["You showed up. That matters.", "لقد حضرت. وهذا مهم."],
	["Calm mind, mighty work.", "عقل هادئ، عمل عظيم."],
	["Every session lays a stone.", "كل جلسة تضع حجرًا."],
]

func quote(i: int) -> String:
	var q = QUOTES[i % QUOTES.size()]
	return q[1] if AppState.language == "ar" else q[0]

func _ready() -> void:
	_load_font()

func _load_font() -> void:
	var path := "res://assets/fonts/Cairo-Regular.ttf"
	if ResourceLoader.exists(path):
		var f = load(path)
		if f is FontFile:
			font = f
			has_arabic = true
			return
	# fall back to engine font (Latin only)
	font = ThemeDB.fallback_font

func is_rtl() -> bool:
	return AppState.language == "ar"

func t(key: String) -> String:
	if not STR.has(key):
		return key
	var pair = STR[key]
	return pair[1] if AppState.language == "ar" else pair[0]

# convenience for "%d"-style strings
func tf(key: String, arg) -> String:
	return t(key) % arg

# digits: render Western numerals in EN, Arabic-Indic in AR for native feel
func num(n) -> String:
	var s := str(n)
	if AppState.language != "ar":
		return s
	var map := {"0":"٠","1":"١","2":"٢","3":"٣","4":"٤","5":"٥","6":"٦","7":"٧","8":"٨","9":"٩"}
	var out := ""
	for ch in s:
		out += map.get(ch, ch)
	return out
