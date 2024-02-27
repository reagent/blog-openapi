#!/usr/bin/env node

import { program } from 'commander';
import { Api } from './openapi';
import { AxiosRequestConfig } from 'axios';

program.name('blog').description('Interact with blog service');

program
  .command('list')
  .description('List posts')
  .option('-u, --username <username>')
  .option('-p, --password <password>')
  .action(async ({ username, password }) => {
    let auth: AxiosRequestConfig['auth'] | undefined;

    if (username && password) {
      auth = { username, password };
    }

    const client = new Api({ auth });

    const { data: response } = await client.posts.postList();

    console.log(`${response.total} post(s) found\n`);

    response.posts.forEach((p) => {
      console.log(` * ${p.title} (${p.published_at})`);
    });

    console.log();
  });

program
  .command('post')
  .description('Create a post')
  .requiredOption('-u, --username <username>', 'Username for auth')
  .requiredOption('-p, --password <password>', 'Password for auth')
  .action(async ({ username, password }) => {
    const p = await import('@clack/prompts');

    const client = new Api({ auth: { username, password } });

    p.intro('Create a New Post');

    const { title, body } = await p.group({
      title: () => p.text({ message: 'Title' }),
      body: () => p.text({ message: 'Body' }),
    });

    const {
      data: { id },
    } = await client.posts.postCreate({ post: { title, body } });

    console.log(`Created post ID #${id}`);
  });

program
  .command('publish')
  .description('Publish post')
  .requiredOption('-u, --username <username>', 'Username for auth')
  .requiredOption('-p, --password <password>', 'Password for auth')
  .action(async ({ username, password }) => {
    const p = await import('@clack/prompts');

    const client = new Api({ auth: { username, password } });

    const {
      data: { posts },
    } = await client.posts.postList();

    // TODO: published_at in future as well
    const unpublished = posts.filter((p) => !p.published_at);

    p.intro('Select post to publish');

    const postId = (await p.select({
      message: 'Post',
      options: unpublished.map((p) => ({ value: p.id, label: p.title })),
    })) as number;

    await client.posts.postPublish(postId);
  });

program.parse();
