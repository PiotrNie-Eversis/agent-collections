import type { Config, Plugin, ConfigureWebpackUtils } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";
import type { Compilation, Configuration, WebpackError } from "webpack";
import type { ConfigureWebpackResult } from "@docusaurus/types/src/plugin";

const config: Config = {
  title: "Agent Collections",
  tagline:
    "Vendor-neutral multi-agent product engineering framework — Ideate → Implement → Review → Fine",

  // Public hosting deferred (Wave D Q3). Local / preview placeholder only — not a production docs URL.
  url: "http://localhost:3000",
  baseUrl: "/",

  onBrokenLinks: "throw",

  markdown: {
    mermaid: true,
  },

  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  presets: [
    [
      "classic",
      {
        docs: {
          sidebarPath: "./sidebars.ts",
          routeBasePath: "docs",
          breadcrumbs: true,
          admonitions: {
            keywords: ["note", "tip", "info", "warning", "danger", "brand"],
          },
          // Skills sidebar: alphabetical by title instead of sidebar_position —
          // 48+ entries with no natural reading order, unlike workflow/getting-started.
          // The generator only runs once at the root ('.') — the "Skills" category
          // already comes back nested inside `items`, so we walk the tree to find it
          // (identified by containing the overview doc) rather than matching dirName.
          sidebarItemsGenerator: async ({
            defaultSidebarItemsGenerator,
            ...args
          }) => {
            const items = await defaultSidebarItemsGenerator(args);
            const titleById = new Map(
              args.docs.map((doc) => [doc.id, doc.title]),
            );

            type SidebarItem = (typeof items)[number];
            const isOverview = (item: SidebarItem) =>
              item.type === "doc" && item.id === "skills/overview";
            const titleOf = (item: SidebarItem): string => {
              if (item.type === "doc") {
                return titleById.get(item.id) ?? item.id;
              }
              return "label" in item && typeof item.label === "string"
                ? item.label
                : "";
            };

            const sortSkillsItems = (skillItems: SidebarItem[]) => {
              const overview = skillItems.filter(isOverview);
              const rest = [...skillItems.filter((i) => !isOverview(i))].sort(
                (a, b) => titleOf(a).localeCompare(titleOf(b)),
              );
              return [...overview, ...rest];
            };

            const withSortedSkills = (
              currentItems: SidebarItem[],
            ): SidebarItem[] => {
              if (currentItems.some(isOverview)) {
                return sortSkillsItems(currentItems);
              }
              return currentItems.map((item) =>
                item.type === "category"
                  ? { ...item, items: withSortedSkills(item.items) }
                  : item,
              );
            };

            return withSortedSkills(items);
          },
        },
        blog: false,
        pages: {},
        theme: {
          customCss: "./src/css/custom.css",
        },
      } satisfies Preset.Options,
    ],
  ],

  plugins: [
    function webpackWarningFilter(): Plugin {
      return {
        name: "webpack-warning-filter",
        configureWebpack(
          _config: Configuration,
          _isServer: boolean,
          _configureWebpackUtils: ConfigureWebpackUtils,
          _content: unknown,
        ): ConfigureWebpackResult {
          return {
            ignoreWarnings: [
              (warning: Error, compilation: Compilation) =>
                warning.message?.includes(
                  "Critical dependency: require function is used",
                ) === true,
            ],
          };
        },
      };
    },
  ],

  themes: [
    "@docusaurus/theme-mermaid",
    [
      "@easyops-cn/docusaurus-search-local",
      {
        hashed: true,
        indexBlog: false,
      },
    ],
  ],

  headTags: [
    {
      tagName: "link",
      attributes: {
        rel: "preconnect",
        href: "https://fonts.googleapis.com",
      },
    },
    {
      tagName: "link",
      attributes: {
        rel: "preconnect",
        href: "https://fonts.gstatic.com",
        crossorigin: "anonymous",
      },
    },
    {
      tagName: "link",
      attributes: {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap",
      },
    },
  ],

  themeConfig: {
    image: "img/opengraph.png",
    metadata: [
      {
        property: "og:type",
        content: "website",
      },
      {
        property: "og:image:width",
        content: "1200",
      },
      {
        property: "og:image:height",
        content: "630",
      },
      {
        property: "og:image:alt",
        content:
          "Agent Collections documentation — vendor-neutral multi-agent product engineering.",
      },
      {
        name: "twitter:image:alt",
        content:
          "Agent Collections documentation — vendor-neutral multi-agent product engineering.",
      },
    ],
    navbar: {
      title: "Agent Collections",
      items: [
        {
          type: "docSidebar",
          sidebarId: "tutorialSidebar",
          position: "left",
          label: "Docs",
        },
        {
          to: "/docs/getting-started/start-here",
          label: "Get started",
          position: "left",
        },
        {
          to: "/docs/framework",
          label: "Framework",
          position: "left",
        },
        {
          to: "/docs/isolation",
          label: "Isolation",
          position: "left",
        },
        {
          to: "/docs/workflow/overview",
          label: "Workflow",
          position: "left",
        },
        {
          type: "dropdown",
          label: "Components",
          position: "left",
          items: [
            {
              to: "/docs/agents/overview",
              label: "Agents",
            },
            {
              to: "/docs/prompts/overview",
              label: "Prompts",
            },
            {
              to: "/docs/skills/overview",
              label: "Skills",
            },
            {
              to: "/docs/integrations/overview",
              label: "Integrations",
            },
          ],
        },
        {
          to: "/docs/use-cases",
          label: "Use Cases",
          position: "left",
        },
        {
          to: "/docs/for-ctos",
          label: "For CTOs",
          position: "left",
          className: "navbar__link--cto",
        },
        {
          to: "/changelog",
          label: "Changelog",
          position: "right",
          className: "navbar__link--meta",
        },
        {
          href: "https://github.com/PiotrNie-Eversis/agent-collections",
          html: `
            <span class="navbar__github-content">
              <svg class="navbar__github-icon" viewBox="0 0 24 24" aria-hidden="true">
                <path d="M12 .5C5.65.5.5 5.65.5 12c0 5.08 3.29 9.39 7.86 10.91.57.11.78-.25.78-.56 0-.27-.01-1.17-.02-2.12-3.2.7-3.88-1.36-3.88-1.36-.52-1.33-1.28-1.68-1.28-1.68-1.05-.72.08-.71.08-.71 1.16.08 1.77 1.19 1.77 1.19 1.03 1.77 2.69 1.26 3.35.97.1-.75.4-1.26.73-1.55-2.56-.29-5.24-1.28-5.24-5.71 0-1.26.45-2.29 1.19-3.1-.12-.29-.52-1.46.11-3.04 0 0 .97-.31 3.19 1.18A11.1 11.1 0 0 1 12 6.13c.98 0 1.98.13 2.91.38 2.22-1.49 3.18-1.18 3.18-1.18.64 1.58.24 2.75.12 3.04.74.81 1.19 1.84 1.19 3.1 0 4.44-2.68 5.41-5.25 5.69.41.35.78 1.03.78 2.08 0 1.5-.01 2.71-.01 3.08 0 .31.2.68.79.56A11.5 11.5 0 0 0 23.5 12C23.5 5.65 18.35.5 12 .5Z" />
              </svg>
              <span class="navbar__github-wordmark">GitHub</span>
              <svg class="navbar__github-arrow" viewBox="0 0 12 12" aria-hidden="true">
                <path d="M3 9 9 3M4 3h5v5" />
              </svg>
            </span>
          `,
          position: "right",
          className: "navbar__link--github",
        },
      ],
    },
    footer: {
      style: "light",
      copyright: `agent-collections · Eversis Agent Collections · MIT licence`,
      links: [
        {
          title: " ",
          items: [
            {
              href: "https://github.com/PiotrNie-Eversis/agent-collections",
              label: "GitHub",
            },
            { label: "Docs", to: "/docs/" },
            { label: "Methodology", to: "/docs/workflow/overview" },
          ],
        },
      ],
    },
    tableOfContents: {
      minHeadingLevel: 2,
      maxHeadingLevel: 4,
    },
    colorMode: {
      defaultMode: "light",
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
