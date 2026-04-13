#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const files = [
  path.join(root, 'project.yml'),
  path.join(root, 'HonestFastingTimer.xcodeproj', 'project.pbxproj'),
];

function parseArgs(argv) {
  const args = { dryRun: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--version') args.version = argv[++i];
    else if (arg === '--build') args.build = argv[++i];
    else if (arg === '--bump-build') args.bumpBuild = true;
    else if (arg === '--dry-run') args.dryRun = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return args;
}

const args = parseArgs(process.argv.slice(2));
const pbxprojPath = files[1];
const pbxproj = fs.readFileSync(pbxprojPath, 'utf8');
const currentVersion = (pbxproj.match(/MARKETING_VERSION = ([^;]+);/) || [])[1];
const currentBuild = (pbxproj.match(/CURRENT_PROJECT_VERSION = ([^;]+);/) || [])[1];
if (!currentVersion || !currentBuild) throw new Error('Could not read current version/build');
const nextVersion = args.version || currentVersion;
const nextBuild = args.build || (args.bumpBuild ? String(Number(currentBuild) + 1) : currentBuild);

const replacements = [
  [/MARKETING_VERSION: ".*?"/g, `MARKETING_VERSION: "${nextVersion}"`],
  [/CURRENT_PROJECT_VERSION: ".*?"/g, `CURRENT_PROJECT_VERSION: "${nextBuild}"`],
  [/MARKETING_VERSION = [^;]+;/g, `MARKETING_VERSION = ${nextVersion};`],
  [/CURRENT_PROJECT_VERSION = [^;]+;/g, `CURRENT_PROJECT_VERSION = ${nextBuild};`],
];

if (args.dryRun) {
  console.log(JSON.stringify({ dryRun: true, version: { from: currentVersion, to: nextVersion }, build: { from: currentBuild, to: nextBuild } }, null, 2));
  process.exit(0);
}

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  for (const [pattern, replacement] of replacements) {
    content = content.replace(pattern, replacement);
  }
  fs.writeFileSync(file, content);
}

console.log(JSON.stringify({ ok: true, version: nextVersion, build: nextBuild }, null, 2));
