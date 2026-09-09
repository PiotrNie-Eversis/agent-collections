import type { Config, Plugin, ConfigureWebpackUtils } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import type { Compilation, Configuration, WebpackError } from 'webpack';
import type { ConfigureWebpackResult } from '@docusaurus/types/src/plugin';

const config: Config = {
  title: 'Agent Collections',
  tagline:
    'Vendor-neutral multi-agent product engineering framework — Ideate → Implement → Review → Fine',

  // Public hosting deferred (Wave D Q3). Local / preview placeholder only — not a production docs URL.
  url: 'http://localhost:3000',
  baseUrl: '/',

  onBrokenLinks: 'throw',

  markdown: {
    mermaid: true,
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: 'docs',
          breadcrumbs: true,
          admonitions: {
            keywords: ['note', 'tip', 'info', 'warning', 'danger', 'brand'],
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
              item.type === 'doc' && item.id === 'skills/overview';
            const titleOf = (item: SidebarItem): string => {
              if (item.type === 'doc') {
                return titleById.get(item.id) ?? item.id;
              }
              return 'label' in item && typeof item.label === 'string'
                ? item.label
                : '';
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
                item.type === 'category'
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
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  plugins: [
    function webpackWarningFilter(): Plugin {
      return {
        name: 'webpack-warning-filter',
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
                  'Critical dependency: require function is used',
                ) === true,
            ],
          };
        },
      };
    },
  ],

  themes: [
    '@docusaurus/theme-mermaid',
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        indexBlog: false,
      },
    ],
  ],

  headTags: [
    {
      tagName: 'link',
      attributes: {
        rel: 'preconnect',
        href: 'https://fonts.googleapis.com',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'preconnect',
        href: 'https://fonts.gstatic.com',
        crossorigin: 'anonymous',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap',
      },
    },
  ],

  themeConfig: {
    image: 'img/opengraph.png',
    metadata: [
      {
        property: 'og:type',
        content: 'website',
      },
      {
        property: 'og:image:width',
        content: '1200',
      },
      {
        property: 'og:image:height',
        content: '630',
      },
      {
        property: 'og:image:alt',
        content:
          'Agent Collections documentation — vendor-neutral multi-agent product engineering.',
      },
      {
        name: 'twitter:image:alt',
        content:
          'Agent Collections documentation — vendor-neutral multi-agent product engineering.',
      },
    ],
    navbar: {
      title: 'Agent Collections',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          to: '/docs/getting-started/start-here/',
          label: 'Get started',
          position: 'left',
        },
        {
          to: '/docs/main-flow/',
          label: 'The Main Flow',
          position: 'left',
        },
        {
          to: '/docs/reference/',
          label: 'Reference',
          position: 'left',
        },
        {
          to: '/docs/advanced/',
          label: 'Advanced / CTO',
          position: 'left',
          className: 'navbar__link--cto',
        },
        {
          to: '/changelog/',
          label: 'Changelog',
          position: 'right',
          className: 'navbar__link--meta',
        },
        {
          href: 'https://gitlab3.eversis.com/eversis-ai/agent-collections',
          html: `
            <span class="navbar__github-content">
              <span class="navbar__github-wordmark">GitLab</span>
              <svg class="navbar__github-arrow" viewBox="0 0 12 12" aria-hidden="true">
                <path d="M3 9 9 3M4 3h5v5" />
              </svg>
            </span>
          `,
          position: 'right',
          className: 'navbar__link--github',
        },
      ],
    },
    footer: {
      style: 'light',
      copyright: `Eversis Agent Collections · MIT licence`,
      links: [
        {
          title: ' ',
          items: [
            {
              href: 'https://gitlab3.eversis.com/eversis-ai/agent-collections',
              label: 'GitLab',
            },
            { label: 'Docs', to: '/docs/' },
            { label: 'Methodology', to: '/docs/main-flow/workflow/overview' },
          ],
        },
      ],
    },
    tableOfContents: {
      minHeadingLevel: 2,
      maxHeadingLevel: 4,
    },
    colorMode: {
      defaultMode: 'light',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
