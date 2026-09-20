import { DEFAULT_LOCALE } from "./locale";
import type { Device, ProjectState, Slide } from "./types";

let _id = 0;
export const nid = () => `s_${Date.now().toString(36)}_${(_id++).toString(36)}`;

const en = (s: string) => ({ [DEFAULT_LOCALE]: s });

// A Way Out — iPhone deck. Narrative arc: hero benefit → choose apps →
// group & lock → physical NFC friction → the deliberate way back.
const IPHONE = "/screenshots/apple/iphone/{locale}";

function makeStarterSlides(): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: en("A WAY OUT"),
      headline: en("Block distracting apps\nwith any NFC tag."),
      screenshot: `${IPHONE}/05.png`,
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: en("CHOOSE"),
      headline: en("Pick exactly what\nsteals your focus."),
      screenshot: `${IPHONE}/02.png`,
    },
    {
      id: nid(),
      layout: "device-top",
      label: en("ORGANIZE"),
      headline: en("Group your blocks.\nLock them in a tap."),
      screenshot: `${IPHONE}/03.png`,
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: en("PHYSICAL FRICTION"),
      headline: en("Tap a real tag.\nBreak the habit."),
      screenshot: `${IPHONE}/04.png`,
    },
    {
      id: nid(),
      layout: "hero",
      label: en("NO SHORTCUTS"),
      headline: en("The only way back\nis a deliberate tap."),
      screenshot: `${IPHONE}/01.png`,
    },
  ];
}

// iPad deck — copy is seeded; drop iPad captures into
// public/screenshots/apple/ipad/en/01.png … 03.png (or via the editor).
const IPAD = "/screenshots/apple/ipad/{locale}";

function ipadStarter(): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: en("A WAY OUT"),
      headline: en("Block distracting apps\nwith any NFC tag."),
      screenshot: `${IPAD}/01.png`,
    },
    {
      id: nid(),
      layout: "device-bottom",
      label: en("CHOOSE"),
      headline: en("Pick exactly what\nsteals your focus."),
      screenshot: `${IPAD}/02.png`,
    },
    {
      id: nid(),
      layout: "device-top",
      label: en("NO SHORTCUTS"),
      headline: en("The only way back\nis a deliberate tap."),
      screenshot: `${IPAD}/03.png`,
    },
  ];
}

function tabletStarter(kind: "7" | "10"): Slide[] {
  return [
    {
      id: nid(),
      layout: "hero",
      label: en("MEET YOUR APP"),
      headline: en(kind === "7" ? "Pocket-sized\npower." : "Made for\nthe big screen."),
      screenshot: "",
    },
    {
      id: nid(),
      layout: "split-landscape",
      label: en("FEATURE 01"),
      headline: en("Wide canvas,\nbigger ideas."),
      screenshot: "",
    },
  ];
}

function fgStarter(): Slide[] {
  return [
    {
      id: nid(),
      layout: "feature-graphic",
      label: {},
      headline: en("Your tagline goes here."),
      screenshot: "",
    },
  ];
}

export const DEFAULT_PROJECT: ProjectState = {
  appName: "A Way Out",
  themeId: "dark-bold",
  locales: [DEFAULT_LOCALE],
  locale: DEFAULT_LOCALE,
  device: "iphone",
  orientation: "portrait",
  appIcon: "/app-icon.png",
  slidesByDevice: {
    iphone: makeStarterSlides(),
    android: makeStarterSlides(),
    ipad: ipadStarter(),
    "android-7": tabletStarter("7"),
    "android-10": tabletStarter("10"),
    "feature-graphic": fgStarter(),
  },
};

export function newSlide(layout: Slide["layout"] = "device-bottom"): Slide {
  return {
    id: nid(),
    layout,
    label: en("NEW"),
    headline: en("Edit this\nheadline."),
    screenshot: "",
  };
}

export function detectPlatform(device: Device): "ios" | "android" {
  return device === "iphone" || device === "ipad" ? "ios" : "android";
}
