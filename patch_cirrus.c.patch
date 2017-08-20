--- patch_cirrus.c.orig	2017-08-20 10:32:27.438923801 +0200
+++ patch_cirrus.c	2017-08-20 10:00:56.726823253 +0200
@@ -29,6 +29,12 @@
 #include "hda_jack.h"
 #include "hda_generic.h"
 
+
+static int hp_out_mask = 1;
+static int speaker_out_mask = 1 << 1;
+module_param(hp_out_mask, int, 0644);
+module_param(speaker_out_mask, int, 0644);
+
 /*
  */
 
@@ -138,6 +144,9 @@
 /* Cirrus Logic CS4213 is like CS4210 but does not have SPDIF input/output */
 #define CS4213_VENDOR_NID	0x09
 
+/* CS8409 */
+#define CS8409_IDX_DEV_CFG	0x01
+#define CS8409_VENDOR_NID	0x47
 
 static inline int cs_vendor_coef_get(struct hda_codec *codec, unsigned int idx)
 {
@@ -1242,6 +1251,334 @@
 	return err;
 }
 
+/* CS8409 */
+enum {
+	CS8409_MBP131,
+	CS8409_GPIO_0,
+};
+
+static void cs8409_fixup_gpio_0(struct hda_codec *codec,
+				const struct hda_fixup *fix, int action)
+{
+	if (action == HDA_FIXUP_ACT_PRE_PROBE) {
+		struct cs_spec *spec = codec->spec;
+
+		printk("fixup gpio hp=0x%x speaker=0x%x", hp_out_mask, speaker_out_mask);
+		spec->gpio_eapd_hp = hp_out_mask;
+		spec->gpio_eapd_speaker = speaker_out_mask;
+		spec->gpio_mask = 0xff;
+		spec->gpio_data =
+		  spec->gpio_dir =
+		  spec->gpio_eapd_hp | spec->gpio_eapd_speaker;
+	}
+}
+
+static const struct hda_model_fixup cs8409_models[] = {
+	{ .id = CS8409_MBP131, .name = "mbp131" },
+	{}
+};
+
+static const struct snd_pci_quirk cs8409_fixup_tbl[] = {
+	SND_PCI_QUIRK(0x106b, 0x3300, "MacBookPro 13,1", CS8409_MBP131),
+	{} /* terminator */
+};
+
+static const struct hda_pintbl mbp131_pincfgs[] = {
+	{} /* terminator */
+};
+
+static const struct hda_fixup cs8409_fixups[] = {
+	[CS8409_MBP131] = {
+		.type = HDA_FIXUP_PINS,
+		.v.pins = mbp131_pincfgs,
+		.chained = true,
+		.chain_id = CS8409_GPIO_0,
+	},
+	[CS8409_GPIO_0] = {
+		.type = HDA_FIXUP_FUNC,
+		.v.func = cs8409_fixup_gpio_0,
+	},
+};
+
+static const struct hda_verb cs8409_coef_init_verbs[] = {
+	{0x47, AC_VERB_SET_PROC_STATE, 0x01},  /* VPW: processing on */
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0000},
+	{0x47, AC_VERB_SET_PROC_COEF, 0xB00C},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0001},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0002},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0002},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0AC3},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0019},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0800},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x001A},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0820},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0029},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0800},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x002A},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x2800},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0039},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0080},
+	
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x003A},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0820},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x003B},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0840},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x003C},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0860},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0003},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x8000},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0004},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x28FF},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0005},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0A62},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0006},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x801F},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0007},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x283F},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0008},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x8A5C},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0001},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0062},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0000},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x900C},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0068},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x000F},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x0082},
+	{0x47, AC_VERB_SET_PROC_COEF, 0xFF03},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x00C0},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x9999},  /* Test mode: on */
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x00C5},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0000},
+
+	{0x47, AC_VERB_SET_COEF_INDEX, 0x00C0},
+	{0x47, AC_VERB_SET_PROC_COEF, 0x0000},  /* Test mode: off */
+
+	{} /* terminator */
+  };
+
+static void cs8409_pinmux_init(struct hda_codec *codec)
+{
+	struct cs_spec *spec = codec->spec;
+	unsigned int coef;
+
+	printk("pinmux pre");
+
+	coef = cs_vendor_coef_get(codec, CS8409_IDX_DEV_CFG);
+
+	printk("pinmux post");
+	//	if (spec->gpio_mask)
+	//		coef |= 0x003f; /* it has 8 GPIOs */
+	//	else
+	//	coef &= ~0x003f;
+
+	//	cs_vendor_coef_set(codec, CS8409_IDX_DEV_CFG, coef);
+}
+
+static void cs8409_spdif_automute(struct hda_codec *codec,
+				  struct hda_jack_callback *tbl)
+{
+	struct cs_spec *spec = codec->spec;
+	bool spdif_present = false;
+	hda_nid_t spdif_pin = spec->gen.autocfg.dig_out_pins[0];
+
+	printk("automute pre");
+
+	/* detect on spdif is specific to CS8409 */
+	if (!spec->spdif_detect ||
+	    spec->vendor_nid != CS8409_VENDOR_NID)
+		return;
+
+	printk("automute 1");
+	spdif_present = snd_hda_jack_detect(codec, spdif_pin);
+	if (spdif_present == spec->spdif_present)
+		return;
+
+	spec->spdif_present = spdif_present;
+	/* SPDIF TX on/off */
+	printk("automute 2");
+	snd_hda_set_pin_ctl(codec, spdif_pin, spdif_present ? PIN_OUT : 0);
+
+	printk("automute 3");
+	cs_automute(codec);
+
+	printk("automute post");
+}
+
+static void parse_cs8409_digital(struct hda_codec *codec)
+{
+	struct cs_spec *spec = codec->spec;
+	struct auto_pin_cfg *cfg = &spec->gen.autocfg;
+	int i;
+
+	printk("digital pre");
+
+	for (i = 0; i < cfg->dig_outs; i++) {
+		hda_nid_t nid = cfg->dig_out_pins[i];
+
+		printk("digital out %d", i);
+		
+		if (get_wcaps(codec, nid) & AC_WCAP_UNSOL_CAP) {
+			spec->spdif_detect = 1;
+			snd_hda_jack_detect_enable_callback(codec, nid,
+							    cs8409_spdif_automute);
+		}
+	}
+
+	printk("digital post");
+}
+
+static int cs8409_init(struct hda_codec *codec)
+{
+	struct cs_spec *spec = codec->spec;
+
+	printk("init pre");
+
+	if (spec->vendor_nid == CS8409_VENDOR_NID) {
+		snd_hda_sequence_write(codec, cs8409_coef_init_verbs);
+		cs8409_pinmux_init(codec);
+	}
+
+	printk("init 1");
+	snd_hda_gen_init(codec);
+
+	if (spec->gpio_mask) {
+	  //		snd_hda_codec_write(codec, 0x01, 0, AC_VERB_SET_GPIO_MASK,
+	  //			    spec->gpio_mask);
+	  //	snd_hda_codec_write(codec, 0x01, 0, AC_VERB_SET_GPIO_DIRECTION,
+	  //			    spec->gpio_dir);
+	  //	snd_hda_codec_write(codec, 0x01, 0, AC_VERB_SET_GPIO_DATA,
+	  //			    spec->gpio_data);
+	}
+
+	//	printk("init 2");
+	//	init_input_coef(codec);
+
+	printk("init post");
+
+	return 0;
+
+}
+
+static int cs8409_build_controls(struct hda_codec *codec)
+{
+	int err;
+
+	printk("controls pre");
+
+	err = snd_hda_gen_build_controls(codec);
+	if (err < 0)
+		return err;
+
+	printk("controls post");
+
+	return 0;
+}
+
+static int cs8409_parse_auto_config(struct hda_codec *codec)
+{
+	struct cs_spec *spec = codec->spec;
+	int err;
+
+	printk("auto config pre");
+
+	err = snd_hda_parse_pin_defcfg(codec, &spec->gen.autocfg, NULL, 0);
+	if (err < 0)
+		return err;
+
+	printk("auto config 1");
+	err = snd_hda_gen_parse_auto_config(codec, &spec->gen.autocfg);
+	if (err < 0)
+		return err;
+
+	printk("auto config 2");
+	parse_cs8409_digital(codec);
+
+	printk("auto config post");
+	
+	return 0;
+}
+
+#ifdef CONFIG_PM
+/*
+	Manage PDREF, when transitioning to D3hot
+	(DAC,ADC) -> D3, PDREF=1, AFG->D3
+*/
+static int cs8409_suspend(struct hda_codec *codec)
+{
+	snd_hda_shutup_pins(codec);
+	return 0;
+}
+#endif
+
+static const struct hda_codec_ops cs8409_patch_ops = {
+	.build_controls = cs8409_build_controls,
+	.build_pcms = snd_hda_gen_build_pcms,
+	.init = cs8409_init,
+	.free = cs_free,
+	.unsol_event = snd_hda_jack_unsol_event,
+#ifdef CONFIG_PM
+	.suspend = cs8409_suspend,
+#endif
+};
+
+static int patch_cs8409(struct hda_codec *codec)
+{
+	struct cs_spec *spec;
+	int err;
+
+	printk("cs8409");
+
+	spec = cs_alloc_spec(codec, CS8409_VENDOR_NID);
+	if (!spec)
+		return -ENOMEM;
+
+	codec->patch_ops = cs8409_patch_ops;
+	//	spec->gen.automute_hook = cs_automute;
+	
+	printk("cs8409 - 1");
+	snd_hda_pick_fixup(codec, cs8409_models, cs8409_fixup_tbl,
+			   cs8409_fixups);
+	printk("cs8409 - 2");
+	snd_hda_apply_fixup(codec, HDA_FIXUP_ACT_PRE_PROBE);
+
+	//	cs8409_pinmux_init(codec);
+
+	printk("cs8409 - 4");
+	err = cs8409_parse_auto_config(codec);
+	if (err < 0)
+		goto error;
+
+	printk("post cs8409");
+
+	return 0;
+
+ error:
+	cs_free(codec);
+	return err;
+}
+
 
 /*
  * patch entries
@@ -1252,6 +1589,7 @@
 	HDA_CODEC_ENTRY(0x10134208, "CS4208", patch_cs4208),
 	HDA_CODEC_ENTRY(0x10134210, "CS4210", patch_cs4210),
 	HDA_CODEC_ENTRY(0x10134213, "CS4213", patch_cs4213),
+	HDA_CODEC_ENTRY(0x10138409, "CS8409", patch_cs8409),
 	{} /* terminator */
 };
 MODULE_DEVICE_TABLE(hdaudio, snd_hda_id_cirrus);
