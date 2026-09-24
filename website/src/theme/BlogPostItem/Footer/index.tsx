import React from 'react';
import Link from '@docusaurus/Link';
import {useBlogPost} from '@docusaurus/plugin-content-blog/client';
import BlogPostItemFooter from '@theme-original/BlogPostItem/Footer';

export default function BlogPostItemFooterWrapper(
  props: React.ComponentProps<typeof BlogPostItemFooter>,
): React.JSX.Element {
  const {isBlogPostPage} = useBlogPost();
  return (
    <>
      <BlogPostItemFooter {...props} />
      {isBlogPostPage && (
        <p className="blog-post-list-cta">
          <Link to="/blog">All posts</Link>
        </p>
      )}
    </>
  );
}
