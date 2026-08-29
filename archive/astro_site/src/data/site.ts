export interface NavLink {
  label: string;
  href: `#${string}`;
}

export interface ProcessStep {
  number: string;
  title: string;
  description: string;
}

export interface ResearchTopic {
  label: string;
  title: string;
  description: string;
  points: string[];
}

export interface FaqItem {
  question: string;
  answer: string;
}

export interface ContactDetail {
  label: string;
  value: string;
}

export const navLinks: NavLink[] = [
  { label: "Home", href: "#home" },
  { label: "How It Works", href: "#how-it-works" },
  { label: "Research", href: "#research" },
  { label: "FAQ", href: "#faq" },
  { label: "Contact", href: "#contact" },
];

export const processSteps: ProcessStep[] = [
  {
    number: "01",
    title: "Observe real routines",
    description:
      "We study social habits, frictions, and moments of ease in the places people already spend time.",
  },
  {
    number: "02",
    title: "Distill what matters",
    description:
      "Patterns become clear principles, prototypes, and prompts that can guide better shared experiences.",
  },
  {
    number: "03",
    title: "Shape the next iteration",
    description:
      "The strongest ideas are refined into tools, pilots, and published learnings that stay grounded in real life.",
  },
];

export const researchTopics: ResearchTopic[] = [
  {
    label: "Focus 01",
    title: "Rituals of belonging",
    description:
      "We look at the small repeated cues that help people feel welcomed, oriented, and ready to participate without pressure.",
    points: ["Invitations and entry points", "Shared pacing", "Signals of warmth"],
  },
  {
    label: "Focus 02",
    title: "Place and mood",
    description:
      "Spatial flow, timing, and atmosphere often decide whether an experience feels open and memorable or merely functional.",
    points: ["Threshold moments", "Lighting and tempo", "Movement through space"],
  },
  {
    label: "Focus 03",
    title: "Digital restraint",
    description:
      "We test where interfaces should guide, where they should step back, and how technology can support presence instead of stealing it.",
    points: ["Low-noise prompts", "Context-aware touchpoints", "Healthy interaction limits"],
  },
];

export const faqItems: FaqItem[] = [
  {
    question: "What is FunApp?",
    answer:
      "FunApp is a research-led concept exploring how design can make shared experiences feel easier, calmer, and more human.",
  },
  {
    question: "Who is this work for?",
    answer:
      "The current direction is relevant to hospitality teams, cultural organizations, product groups, and anyone shaping social environments with care.",
  },
  {
    question: "Do you publish research as it develops?",
    answer:
      "Yes. We aim to share concise field notes, prototypes, and selected essays as ideas become strong enough to be useful to others.",
  },
  {
    question: "Are collaborations possible at this stage?",
    answer:
      "We are open to a small number of thoughtful partnerships when there is a clear question to investigate and room to test ideas responsibly.",
  },
  {
    question: "Is this a finished product?",
    answer:
      "Not yet. This first version introduces the mission, methods, and research themes guiding what comes next.",
  },
];

export const contactDetails: ContactDetail[] = [
  {
    label: "Email",
    value: "hello@funapp.studio",
  },
  {
    label: "Focus",
    value: "Research partnerships, editorial projects, and thoughtful digital experiences.",
  },
  {
    label: "Response",
    value: "Usually within three business days once we have enough context to reply well.",
  },
];

export const footerYear = new Date().getFullYear();
