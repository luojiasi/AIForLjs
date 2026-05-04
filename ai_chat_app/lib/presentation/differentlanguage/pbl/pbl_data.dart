import 'package:flutter/material.dart';

/// ============================================================
/// Data models for Project-Based Learning tutorial catalog
/// Source: https://github.com/practical-tutorials/project-based-learning
/// ============================================================

class PBLTutorial {
  final String title;
  final String url;
  const PBLTutorial(this.title, this.url);
}

class PBLSubCategory {
  final String name;
  final List<PBLTutorial> tutorials;
  const PBLSubCategory(this.name, this.tutorials);
}

class PBLLanguage {
  final String name;
  final IconData icon;
  final Color color;
  final List<PBLSubCategory> subCategories;

  int get tutorialCount =>
      subCategories.fold(0, (sum, sc) => sum + sc.tutorials.length);

  const PBLLanguage(
    this.name,
    this.icon,
    this.color,
    this.subCategories,
  );
}

/// All 23 languages + additional resources, with 300+ tutorials
const List<PBLLanguage> pblAllLanguages = [
  // ── C/C++ ────────────────────────────────────────────────
  PBLLanguage(
    'C/C++',
    Icons.memory,
    Color(0xFF00599C),
    [
      PBLSubCategory('General', [
        PBLTutorial('Build an Interpreter', 'http://www.craftinginterpreters.com/'),
        PBLTutorial('Memory Allocators 101', 'https://arjunsreedharan.org/post/148675821737/memory-allocators-101-write-a-simple-memory'),
        PBLTutorial('Write a Shell in C', 'https://brennan.io/2015/01/16/write-a-shell-in-c/'),
        PBLTutorial('Write a FUSE Filesystem', 'https://www.cs.nmsu.edu/~pfeiffer/fuse-tutorial/'),
        PBLTutorial('Build Your Own Text Editor', 'http://viewsourcecode.org/snaptoken/kilo/'),
        PBLTutorial('Build Your Own Lisp', 'http://www.buildyourownlisp.com/'),
        PBLTutorial('How to Program an NES Game in C', 'https://nesdoug.com/'),
        PBLTutorial('Write an OS from scratch', 'https://github.com/tuhdo/os01'),
        PBLTutorial('How to create an OS from scratch', 'https://github.com/cfenollosa/os-tutorial'),
        PBLTutorial('Building a CHIP-8 Emulator', 'https://austinmorlan.com/posts/chip8_emulator/'),
        PBLTutorial('Beginning Game Programming with C++ and SDL', 'http://lazyfoo.net/tutorials/SDL/'),
        PBLTutorial('Implementing a Key-Value Store', 'http://codecapsule.com/2012/11/07/ikvs-implementing-a-key-value-store-table-of-contents/'),
        PBLTutorial('Tiny Renderer: software rendering in 500 lines', 'https://github.com/ssloy/tinyrenderer/wiki'),
        PBLTutorial('Understandable RayTracing in 256 lines of C++', 'https://github.com/ssloy/tinyraytracer/wiki'),
        PBLTutorial('KABOOM! in 180 lines of bare C++', 'https://github.com/ssloy/tinykaboom/wiki'),
        PBLTutorial('486 lines of C++: old-school FPS in a weekend', 'https://github.com/ssloy/tinyraycaster/wiki'),
        PBLTutorial('Writing a minimal x86-64 JIT compiler in C++ Part 1', 'https://solarianprogrammer.com/2018/01/10/writing-minimal-x86-64-jit-compiler-cpp/'),
        PBLTutorial('Writing a minimal x86-64 JIT compiler in C++ Part 2', 'https://solarianprogrammer.com/2018/01/12/writing-minimal-x86-64-jit-compiler-cpp-part-2/'),
        PBLTutorial('Build a Live Code-reloader Library for C++', 'http://howistart.org/posts/cpp/1/index.html'),
        PBLTutorial('Write a hash table in C', 'https://github.com/jamesroutley/write-a-hash-table'),
        PBLTutorial('Let\'s Build a Simple Database', 'https://cstack.github.io/db_tutorial/'),
        PBLTutorial('Let\'s Write a Kernel', 'http://arjunsreedharan.org/post/82710718100/kernel-101-lets-write-a-kernel'),
        PBLTutorial('Write a Bootloader in C', 'http://3zanders.co.uk/2017/10/13/writing-a-bootloader/'),
        PBLTutorial('Linux Container in 500 Lines of Code', 'https://blog.lizzie.io/linux-containers-in-500-loc.html'),
        PBLTutorial('Write Your Own Virtual Machine', 'https://justinmeiners.github.io/lc3-vm/'),
        PBLTutorial('Learning KVM - Implement Your Own Linux Kernel', 'https://david942j.blogspot.com/2018/10/note-learning-kvm-implement-your-own.html'),
        PBLTutorial('Build Your Own Redis with C/C++', 'https://build-your-own.org/redis/'),
        PBLTutorial('Write a C Compiler (10-part series)', 'https://norasandler.com/2017/11/29/Write-a-Compiler.html'),
        PBLTutorial('Implementing a Language with LLVM', 'https://llvm.org/docs/tutorial/'),
        PBLTutorial('Meta Crush Saga: a C++17 compile-time game', 'https://jguegant.github.io/blogs/tech/meta-crush-saga.html'),
        PBLTutorial('High-Performance Matrix Multiplication', 'https://gist.github.com/nadavrot/5b35d44e8ba3dd718e595e40184d03f0'),
        PBLTutorial('Space Invaders from Scratch (5-part series)', 'http://nicktasios.nl/posts/space-invaders-from-scratch-part-1.html'),
        PBLTutorial('Tetris Tutorial in C++ Platform Independent', 'http://javilop.com/gamedev/tetris-tutorial-in-c-platform-independent-focused-in-game-logic-for-beginners/'),
        PBLTutorial('Writing a Linux Debugger (10-part series)', 'https://blog.tartanllama.xyz/writing-a-linux-debugger-setup/'),
        PBLTutorial('Let\'s write a compiler (8-part series)', 'https://briancallahan.net/blog/20210814.html'),
      ]),
      PBLSubCategory('Network Programming', [
        PBLTutorial('Let\'s Code a TCP/IP Stack (5-part series)', 'http://www.saminiir.com/lets-code-tcp-ip-stack-1-ethernet-arp/'),
        PBLTutorial('Programming concurrent servers (6-part series)', 'https://eli.thegreenplace.net/2017/concurrent-servers-part-1-introduction/'),
        PBLTutorial('MQTT Broker from scratch (7-part series)', 'https://codepr.github.io/posts/sol-mqtt-broker'),
      ]),
      PBLSubCategory('OpenGL', [
        PBLTutorial('Creating 2D Breakout game clone in C++ with OpenGL', 'https://learnopengl.com/In-Practice/2D-Game/Breakout'),
        PBLTutorial('Handmade Hero', 'https://handmadehero.org'),
        PBLTutorial('How to Make Minecraft in C++/OpenGL (video)', 'https://www.youtube.com/playlist?list=PLMZ_9w2XRxiZq1vfw1lrpCMRDufe2MKV_'),
      ]),
    ],
  ),

  // ── C# ────────────────────────────────────────────────────
  PBLLanguage(
    'C#',
    Icons.tag,
    Color(0xFF68217A),
    [
      PBLSubCategory('General', [
        PBLTutorial('Learn C# By Building a Simple RPG Game', 'http://scottlilly.com/learn-c-by-building-a-simple-rpg-index/'),
        PBLTutorial('Create a Rogue-like game in C#', 'https://roguesharp.wordpress.com/'),
        PBLTutorial('Create a Blank App with C# and Xamarin', 'https://www.intertech.com/Blog/xamarin-tutorial-part-1-create-a-blank-app/'),
        PBLTutorial('Build iOS Photo Library App with Xamarin and Visual Studio', 'https://www.raywenderlich.com/134049/building-ios-apps-with-xamarin-and-visual-studio'),
        PBLTutorial('Building the CoreWiki (video series)', 'https://www.youtube.com/playlist?list=PLVMqA0_8O85yC78I4Xj7z48ES48IQBa7p'),
      ]),
    ],
  ),

  // ── Clojure ───────────────────────────────────────────────
  PBLLanguage(
    'Clojure',
    Icons.auto_awesome,
    Color(0xFF5881D8),
    [
      PBLSubCategory('General', [
        PBLTutorial('Build a Twitter Bot with Clojure', 'http://howistart.org/posts/clojure/1/index.html'),
        PBLTutorial('Building a Spell-Checker', 'https://bernhardwenzel.com/articles/clojure-spellchecker/'),
        PBLTutorial('Building a JIRA integration with Clojure & Atlassian Connect', 'https://hackernoon.com/building-a-jira-integration-with-clojure-atlassian-connect-506ebd112807'),
        PBLTutorial('Prototyping with Clojure', 'https://github.com/aliaksandr-s/prototyping-with-clojure'),
        PBLTutorial('Tetris in ClojureScript', 'https://shaunlebron.github.io/t3tr0s-slides'),
      ]),
    ],
  ),

  // ── Dart / Flutter ────────────────────────────────────────
  PBLLanguage(
    'Dart / Flutter',
    Icons.flutter_dash,
    Color(0xFF02569B),
    [
      PBLSubCategory('Flutter Projects', [
        PBLTutorial('Amazon Clone with Admin Panel', 'https://youtu.be/O3nmP-lZAdg'),
        PBLTutorial('Food Delivery App', 'https://youtu.be/7dAt-JMSCVQ'),
        PBLTutorial('Google Docs Clone', 'https://youtu.be/0_GJ1w_iG44'),
        PBLTutorial('Instagram Clone', 'https://youtu.be/mEPm9w5QlJM'),
        PBLTutorial('Multiplayer TicTacToe Game', 'https://youtu.be/Aut-wfXacXg'),
        PBLTutorial('TikTok Clone', 'https://youtu.be/4E4V9F3cbp4'),
        PBLTutorial('Ticket Booking App', 'https://youtu.be/71AsYo2q_0Y'),
        PBLTutorial('Travel App', 'https://youtu.be/x4DydJKVvQk'),
        PBLTutorial('Twitch Clone', 'https://youtu.be/U9YKZrDX0CQ'),
        PBLTutorial('WhatsApp Clone', 'https://youtu.be/yqwfP2vXWJQ'),
        PBLTutorial('Wordle Clone', 'https://youtu.be/_W0RN_Cqhpg'),
        PBLTutorial('Zoom Clone', 'https://youtu.be/sMA1dKbv33Y'),
        PBLTutorial('Netflix Clone', 'https://youtu.be/J8IFNKzs3TI'),
      ]),
    ],
  ),

  // ── Elixir ────────────────────────────────────────────────
  PBLLanguage(
    'Elixir',
    Icons.water_drop,
    Color(0xFF4B275F),
    [
      PBLSubCategory('General', [
        PBLTutorial('Building a Simple Chat App With Elixir and Phoenix', 'https://sheharyar.me/blog/simple-chat-phoenix-elixir/'),
        PBLTutorial('Write a super fast link shortener with Elixir, Phoenix, and Mnesia', 'https://medium.com/free-code-camp/how-to-write-a-super-fast-link-shortener-with-elixir-phoenix-and-mnesia-70ffa1564b3c'),
      ]),
    ],
  ),

  // ── Erlang ────────────────────────────────────────────────
  PBLLanguage(
    'Erlang',
    Icons.settings_ethernet,
    Color(0xFFA90533),
    [
      PBLSubCategory('General', [
        PBLTutorial('ChatBus: build your first multi-user chat room app with Erlang/OTP', 'https://medium.com/@kansi/chatbus-build-your-first-multi-user-chat-room-app-with-erlang-otp-b55f72064901'),
        PBLTutorial('Making a Chat App with Erlang, Rebar, Cowboy and Bullet', 'http://marianoguerra.org/posts/making-a-chat-app-with-erlang-rebar-cowboy-and-bullet.html'),
      ]),
    ],
  ),

  // ── F# ────────────────────────────────────────────────────
  PBLLanguage(
    'F#',
    Icons.functions,
    Color(0xFF378BBA),
    [
      PBLSubCategory('General', [
        PBLTutorial('Write your own Excel in 100 lines of F#', 'http://tomasp.net/blog/2018/write-your-own-excel'),
      ]),
    ],
  ),

  // ── Go ────────────────────────────────────────────────────
  PBLLanguage(
    'Go',
    Icons.golf_course,
    Color(0xFF00ADD8),
    [
      PBLSubCategory('Web & API', [
        PBLTutorial('Create a Real Time Chat App with Golang, Angular 2, and WebSocket', 'https://www.thepolyglotdeveloper.com/2016/12/create-real-time-chat-app-golang-angular-2-websockets/'),
        PBLTutorial('Building Go Web Applications and Microservices Using Gin', 'https://semaphoreci.com/community/tutorials/building-go-web-applications-and-microservices-using-gin'),
        PBLTutorial('How to Use Godog for Behavior-driven Development in Go', 'https://semaphoreci.com/community/tutorials/how-to-use-godog-for-behavior-driven-development-in-go'),
        PBLTutorial('Build Web Application with GoLang', 'https://astaxie.gitbooks.io/build-web-application-with-golang/content/en/'),
        PBLTutorial('Building a Chat Application in Go with ReactJS (6-part series)', 'https://tutorialedge.net/projects/chat-system-in-go-and-react/part-1-initial-setup/'),
        PBLTutorial('Go WebAssembly Tutorial - Building a Calculator', 'https://tutorialedge.net/golang/go-webassembly-tutorial/'),
        PBLTutorial('REST Servers in Go (7-part series)', 'https://eli.thegreenplace.net/2021/rest-servers-in-go-part-1-standard-library/'),
        PBLTutorial('Build a URL shortener in Go - with Gin & Redis (4-part series)', 'https://www.eddywm.com/lets-build-a-url-shortener-in-go/'),
        PBLTutorial('Building a TCP Chat in Go (video)', 'https://www.youtube.com/watch?v=Sphme0BqJiY'),
        PBLTutorial('REST API masterclass with Go, PostgreSQL and Docker (video series)', 'https://www.youtube.com/watch?v=rx6CPDK_5mU&list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE'),
      ]),
      PBLSubCategory('Systems', [
        PBLTutorial('Building Blockchain in Go (7-part series)', 'https://jeiwan.net/posts/building-blockchain-in-go-part-1/'),
        PBLTutorial('Building a container from scratch in Go (video)', 'https://www.youtube.com/watch?v=8fi7uSYlOdc'),
        PBLTutorial('Building a BitTorrent client from the ground up in Go', 'https://blog.jse.li/posts/torrent/'),
      ]),
    ],
  ),

  // ── Haskell ───────────────────────────────────────────────
  PBLLanguage(
    'Haskell',
    Icons.auto_fix_high,
    Color(0xFF5E5086),
    [
      PBLSubCategory('General', [
        PBLTutorial('Write You a Haskell - Build a modern functional compiler', 'http://dev.stephendiehl.com/fun/'),
        PBLTutorial('Write Yourself a Scheme in 48 hours', 'https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours'),
        PBLTutorial('Write You A Scheme, Version 2', 'https://github.com/write-you-a-scheme-v2/scheme'),
        PBLTutorial('Roll Your Own IRC Bot', 'https://wiki.haskell.org/Roll_your_own_IRC_bot'),
        PBLTutorial('Making Movie Monad', 'https://lettier.github.io/posts/2016-08-15-making-movie-monad.html'),
        PBLTutorial('Making a Website with Haskell', 'http://adit.io/posts/2013-04-15-making-a-website-with-haskell.html'),
      ]),
    ],
  ),

  // ── HTML/CSS ──────────────────────────────────────────────
  PBLLanguage(
    'HTML/CSS',
    Icons.web,
    Color(0xFFE34F26),
    [
      PBLSubCategory('Core', [
        PBLTutorial('Build A Loading Screen', 'https://medium.freecodecamp.org/how-to-build-a-delightful-loading-screen-in-5-minutes-847991da509f'),
        PBLTutorial('Build an HTML Calculator with JS', 'https://medium.freecodecamp.org/how-to-build-an-html-calculator-app-from-scratch-using-javascript-4454b8714b98'),
        PBLTutorial('Build Snake using only JavaScript, HTML & CSS', 'https://www.freecodecamp.org/news/think-like-a-programmer-how-to-build-snake-using-only-javascript-html-and-css-7b1479c3339e/'),
      ]),
      PBLSubCategory('Mobile Application', [
        PBLTutorial('Build a React Native Todo Application', 'https://egghead.io/courses/build-a-react-native-todo-application'),
        PBLTutorial('Build a React Native Application with Redux Thunk', 'https://medium.com/@alialhaddad/how-to-use-redux-thunk-in-react-and-react-native-4743a1321bd0'),
      ]),
      PBLSubCategory('React', [
        PBLTutorial('Create Serverless React.js Apps', 'http://serverless-stack.com/'),
        PBLTutorial('Create a Trello Clone', 'http://codeloveandboards.com/blog/2016/01/04/trello-tribute-with-phoenix-and-react-pt-1/'),
        PBLTutorial('Create a Character Voting App with React, Node, MongoDB and SocketIO', 'http://sahatyalkabov.com/create-a-character-voting-app-using-react-nodejs-mongodb-and-socketio'),
        PBLTutorial('React Tutorial: Cloning Yelp', 'https://www.fullstackreact.com/articles/react-tutorial-cloning-yelp/'),
        PBLTutorial('Build a Full Stack Movie Voting App with Test-First Development', 'https://teropa.info/blog/2015/09/10/full-stack-redux-tutorial.html'),
        PBLTutorial('Build a Twitter Stream with React and Node', 'https://scotch.io/tutorials/build-a-real-time-twitter-stream-with-node-and-react-js'),
        PBLTutorial('Build A Simple Medium Clone using React.js and Node.js', 'https://medium.com/@kris101/clone-medium-on-node-js-and-react-js-731cdfbb6878'),
        PBLTutorial('Integrate MailChimp in JS', 'https://medium.freecodecamp.org/how-to-integrate-mailchimp-in-a-javascript-web-app-2a889fb43f6f'),
        PBLTutorial('Build A Chrome Extension with React + Parcel', 'https://medium.freecodecamp.org/building-chrome-extensions-in-react-parcel-79d0240dd58f'),
        PBLTutorial('Build A ToDo App With React Native', 'https://blog.hasura.io/tutorial-fullstack-react-native-with-graphql-and-authentication-18183d13373a'),
        PBLTutorial('Make a Chat Application', 'https://medium.freecodecamp.org/how-to-build-a-chat-application-using-react-redux-redux-saga-and-web-sockets-47423e4bc21a'),
        PBLTutorial('Create a News App with React Native', 'https://medium.freecodecamp.org/create-a-news-app-using-react-native-ced249263627'),
        PBLTutorial('Learn Webpack For React', 'https://medium.freecodecamp.org/learn-webpack-for-react-a36d4cac5060'),
        PBLTutorial('Testing React App With Puppeteer and Jest', 'https://blog.bitsrc.io/testing-your-react-app-with-puppeteer-and-jest-c72b3dfcde59'),
        PBLTutorial('Build Your Own React Boilerplate', 'https://medium.freecodecamp.org/how-to-build-your-own-react-boilerplate-2f8cbbeb9b3f'),
        PBLTutorial('Code The Game Of Life With React', 'https://medium.freecodecamp.org/create-gameoflife-with-react-in-one-hour-8e686a410174'),
        PBLTutorial('A Basic React+Redux Introductory Tutorial', 'https://hackernoon.com/a-basic-react-redux-introductory-tutorial-adcc681eeb5e'),
        PBLTutorial('Build an Appointment Scheduler', 'https://hackernoon.com/build-an-appointment-scheduler-using-react-twilio-and-cosmic-js-95377f6d1040'),
        PBLTutorial('Build A Chat App with Sentiment Analysis', 'https://codeburst.io/build-a-chat-app-with-sentiment-analysis-using-next-js-c43ebf3ea643'),
        PBLTutorial('Build A Full Stack Web Application Setup', 'https://hackernoon.com/full-stack-web-application-using-react-node-js-express-and-webpack-97dbd5b9d708'),
        PBLTutorial('Create Todoist clone with React and Firebase (video)', 'https://www.youtube.com/watch?v=hT3j87FMR6M'),
        PBLTutorial('Build A Random Quote Machine (6-part series)', 'https://www.youtube.com/watch?v=3QngsWA9IEE'),
        PBLTutorial('React Phone E-Commerce Project (video)', 'https://www.youtube.com/watch?v=-edmQKcOW8s'),
      ]),
      PBLSubCategory('Angular', [
        PBLTutorial('Build an Instagram Clone with Angular 1.x', 'https://hackhands.com/building-instagram-clone-angularjs-satellizer-nodejs-mongodb/'),
        PBLTutorial('Build an offline-capable Hacker News client with Angular 2+', 'https://houssein.me/angular2-hacker-news'),
        PBLTutorial('Build a Google+ clone with Django and AngularJS', 'https://thinkster.io/django-angularjs-tutorial'),
        PBLTutorial('Build A Beautiful Real World App with Angular 8 (2-part series)', 'https://medium.com/@hamedbaatour/build-a-real-world-beautiful-web-app-with-angular-6-a-to-z-ultimate-guide-2018-part-i-e121dd1d55e'),
        PBLTutorial('Build Responsive layout with BootStrap 4 and Angular 6', 'https://medium.com/@tomastrajan/how-to-build-responsive-layouts-with-bootstrap-4-and-angular-6-cfbb108d797b'),
        PBLTutorial('ToDo App with Angular 5', 'http://www.discoversdk.com/blog/intro-to-angular-and-the-evolution-of-the-web'),
      ]),
      PBLSubCategory('Node.js', [
        PBLTutorial('Build a real-time Markdown Editor with NodeJS', 'https://scotch.io/tutorials/building-a-real-time-markdown-viewer'),
        PBLTutorial('Test-Driven Development with Node, Postgres and Knex', 'http://mherman.org/blog/2016/04/28/test-driven-development-with-node/'),
        PBLTutorial('Write a Twitter Bot in Node.js (2-part series)', 'https://codeburst.io/build-a-simple-twitter-bot-with-node-js-in-just-38-lines-of-code-ed92db9eb078'),
        PBLTutorial('Build A Simple Search Bot in 30 minutes', 'https://medium.freecodecamp.org/how-to-build-a-simple-search-bot-in-30-minutes-eb56fcedcdb1'),
        PBLTutorial('Build A Job Scraping Web App', 'https://medium.freecodecamp.org/how-i-built-a-job-scraping-web-app-using-node-js-and-indreed-7fbba124bbdc'),
        PBLTutorial('Building a GitHub App', 'https://blog.scottlogic.com/2017/05/22/gifbot-github-integration.html'),
        PBLTutorial('How to build your own Uber-for-X App (2-part series)', 'https://www.ashwinhariharan.tech/blog/how-to-build-your-own-uber-for-x-app/'),
      ]),
      PBLSubCategory('Vue', [
        PBLTutorial('Vue 2 + Firebase: Authentication system in 15 minutes', 'https://medium.com/@anas.mammeri/vue-2-firebase-how-to-build-a-vue-app-with-firebase-authentication-system-in-15-minutes-fdce6f289c3c'),
        PBLTutorial('Vue.js Application Tutorial – Creating a Simple Budgeting App', 'https://matthiashager.com/complete-vuejs-application-tutorial/'),
        PBLTutorial('Build a Blog with Vue, GraphQL and Apollo', 'https://scotch.io/tutorials/build-a-blog-with-vue-graphql-and-apollo-client'),
        PBLTutorial('Build a full stack web application using MEVN stack (2-part series)', 'https://medium.com/@anaida07/mevn-stack-application-part-1-3a27b61dcae0'),
        PBLTutorial('Vue.js To-Do List Tutorial (video)', 'https://www.youtube.com/watch?v=78tNYZUS-ps'),
        PBLTutorial('Vue 2 + Pub/Sub: Build a peer to peer multi-user platform for games', 'https://www.ably.io/tutorials/peer-to-peer-vue'),
      ]),
      PBLSubCategory('Others (Hapi, Express, PWA)', [
        PBLTutorial('Build a Progressive Web Application (PWA) (3-part series)', 'https://bitsofco.de/bitsofcode-pwa-part-1-offline-first-with-service-worker/'),
        PBLTutorial('Build A Native Desktop App with JS', 'https://medium.freecodecamp.org/build-native-desktop-apps-with-javascript-a49ede90d8e9'),
        PBLTutorial('Build a Powerful API with NodeJs, GraphQL and Hapi', 'https://medium.com/@wesharehoodies/how-to-setup-a-powerful-api-with-nodejs-graphql-mongodb-hapi-and-swagger-e251ac189649'),
      ]),
      PBLSubCategory('D3.js', [
        PBLTutorial('Learn D3 using examples', 'https://www.sitepoint.com/d3-js-data-visualizations/'),
        PBLTutorial('Learn To Make A Line Chart', 'https://medium.freecodecamp.org/learn-to-create-a-line-chart-using-d3-js-4f43f1ee716b'),
      ]),
      PBLSubCategory('Game Development', [
        PBLTutorial('Make 2D Breakout Game using Phaser', 'https://developer.mozilla.org/en-US/docs/Games/Tutorials/2D_breakout_game_Phaser'),
        PBLTutorial('Make Flappy Bird in HTML5 and JavaScript with Phaser (2-part series)', 'http://www.lessmilk.com/tutorial/flappy-bird-phaser-1'),
      ]),
      PBLSubCategory('Desktop Application', [
        PBLTutorial('Build A Desktop Chat App with React and Electron', 'https://medium.freecodecamp.org/build-a-desktop-chat-app-with-react-electron-and-chatkit-744d168e6f2f'),
      ]),
      PBLSubCategory('Miscellaneous', [
        PBLTutorial('How to Build a Web Framework in Less Than 20 Lines of Code', 'https://www.pubnub.com/blog/build-yourself-a-web-framework-in-less-than-20-lines-of-code/'),
        PBLTutorial('Build Yourself a Redux', 'https://zapier.com/engineering/how-to-build-redux/'),
        PBLTutorial('How to write your own Virtual DOM', 'https://medium.com/@deathmood/how-to-write-your-own-virtual-dom-ee74acc13060'),
        PBLTutorial('Build A Realtime Serverless GraphQL API with WebSockets on AWS', 'https://andrewgriffithsonline.com/blog/serverless-websockets-on-aws/'),
      ]),
    ],
  ),

  // ── Java ──────────────────────────────────────────────────
  PBLLanguage(
    'Java',
    Icons.coffee,
    Color(0xFFED8B00),
    [
      PBLSubCategory('General', [
        PBLTutorial('Build an Interpreter (Chapters 4-13 in Java)', 'http://www.craftinginterpreters.com/'),
        PBLTutorial('Build a Simple HTTP Server with Java', 'http://javarevisited.blogspot.com/2015/06/how-to-create-http-server-in-java-serversocket-example.html'),
        PBLTutorial('Build an Android Flashlight App (video)', 'https://www.youtube.com/watch?v=dhWL4DC7Krs'),
        PBLTutorial('Build a Spring Boot App with User Authentication', 'https://spring.io/guides/gs/securing-web/'),
      ]),
    ],
  ),

  // ── JavaScript ────────────────────────────────────────────
  PBLLanguage(
    'JavaScript',
    Icons.javascript,
    Color(0xFFF7DF1E),
    [
      PBLSubCategory('General', [
        PBLTutorial('Build 30 things in 30 days with 30 tutorials', 'https://javascript30.com'),
        PBLTutorial('Build an App in Pure JS', 'https://medium.com/codingthesmartway-com-blog/pure-javascript-building-a-real-world-application-from-scratch-5213591cfcd6'),
        PBLTutorial('Build a Jupyter Notebook Extension', 'https://link.medium.com/wWUO7TN8SS'),
        PBLTutorial('Build a TicTacToe Game with JavaScript', 'https://medium.com/javascript-in-plain-english/build-tic-tac-toe-game-using-javascript-3afba3c8fdcc'),
        PBLTutorial('Build a Simple Weather App With Vanilla JavaScript', 'https://webdesign.tutsplus.com/tutorials/build-a-simple-weather-app-with-vanilla-javascript--cms-33893'),
        PBLTutorial('Build a Todo List App in JavaScript', 'https://github.com/dwyl/javascript-todo-list-tutorial'),
      ]),
    ],
  ),

  // ── Kotlin ────────────────────────────────────────────────
  PBLLanguage(
    'Kotlin',
    Icons.android,
    Color(0xFF7F52FF),
    [
      PBLSubCategory('General', [
        PBLTutorial('Keddit - Learn Kotlin While Developing an Android Application', 'https://medium.com/@juanchosaravia/learn-kotlin-while-developing-an-android-app-introduction-567e21ff9664'),
      ]),
    ],
  ),

  // ── Lua ───────────────────────────────────────────────────
  PBLLanguage(
    'Lua',
    Icons.sports_esports,
    Color(0xFF00007C),
    [
      PBLSubCategory('LÖVE Game Engine', [
        PBLTutorial('BYTEPATH: Creation of a Complete Game with Lua and LÖVE (15-part series)', 'https://github.com/SSYGEN/blog/issues/30'),
      ]),
    ],
  ),

  // ── OCaml ─────────────────────────────────────────────────
  PBLLanguage(
    'OCaml',
    Icons.architecture,
    Color(0xFFEC6813),
    [
      PBLSubCategory('General', [
        PBLTutorial('Implement a Language with LLVM in OCaml', 'https://llvm.org/docs/tutorial/'),
        PBLTutorial('Writing a Game Boy Emulator in OCaml', 'https://linoscope.github.io/writing-a-game-boy-emulator-in-ocaml/'),
      ]),
    ],
  ),

  // ── PHP ───────────────────────────────────────────────────
  PBLLanguage(
    'PHP',
    Icons.dns,
    Color(0xFF777BB4),
    [
      PBLSubCategory('Laravel', [
        PBLTutorial('How To Build A Blog With Laravel (video series)', 'https://www.youtube.com/playlist?list=PLwAKR305CRO-Q90J---jXVzbOd4CDRbVx'),
        PBLTutorial('Building Realtime Chat App with Laravel 5.4 and VueJS (video series)', 'https://www.youtube.com/playlist?list=PLXsbBbd36_uVjOFH_P25__XAyGsohXWlv'),
        PBLTutorial('Build A Social Network: Laravel 5 (video series)', 'https://www.youtube.com/playlist?list=PLfdtiltiRHWGGxaR6uFtwZnnbcXqyq8JD'),
        PBLTutorial('Build a full-featured multi-tenant app with Laravel (7-part series)', 'https://medium.com/@ashokgelal/writing-a-full-featured-multi-tenant-laravel-app-from-scratch-a0e1a7350d9d'),
        PBLTutorial('Build a Laravel CRUD Application From Scratch', 'https://www.codewall.co.uk/laravel-crud-demo-with-resource-controller-tutorial/'),
      ]),
      PBLSubCategory('General', [
        PBLTutorial('Make Your Own Blog (in Pure PHP)', 'http://ilovephp.jondh.me.uk/en/tutorial/make-your-own-blog'),
        PBLTutorial('Build A Real Estate Website Example with SilverStripe', 'https://www.silverstripe.org/learn/lessons/'),
      ]),
    ],
  ),

  // ── Python ────────────────────────────────────────────────
  PBLLanguage(
    'Python',
    Icons.code,
    Color(0xFF3776AB),
    [
      PBLSubCategory('Web Scraping', [
        PBLTutorial('Mining Twitter Data with Python', 'https://marcobonzanini.com/2015/03/02/mining-twitter-data-with-python-part-1/'),
        PBLTutorial('Scrape a Website with Scrapy and MongoDB', 'https://realpython.com/blog/python/web-scraping-with-scrapy-and-mongodb/'),
        PBLTutorial('How To Scrape With Python and Selenium WebDriver', 'http://www.byperth.com/2018/04/25/guide-web-scraping-101-what-you-need-to-know-and-how-to-scrape-with-python-selenium-webdriver/'),
        PBLTutorial('Which Movie Should I Watch using BeautifulSoup', 'https://medium.com/@nishantsahoo.in/which-movie-should-i-watch-5c83a3c0f5b1'),
      ]),
      PBLSubCategory('Web Applications', [
        PBLTutorial('Build a Microblog with Flask', 'https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world'),
        PBLTutorial('Create a Blog Web App In Django', 'https://tutorial.djangogirls.org/en/'),
        PBLTutorial('Choose Your Own Adventure Presentations', 'https://www.twilio.com/blog/2015/03/choose-your-own-adventures-presentations-wizard-mode-part-1-of-3.html'),
        PBLTutorial('Build a Todo List with Flask and RethinkDB', 'https://realpython.com/blog/python/rethink-flask-a-simple-todo-list-powered-by-flask-and-rethinkdb/'),
        PBLTutorial('Build a Todo List with Django and Test-Driven Development', 'http://www.obeythetestinggoat.com/'),
        PBLTutorial('Build a RESTful Microservice in Python', 'http://www.skybert.net/python/developing-a-restful-micro-service-in-python/'),
        PBLTutorial('Microservices with Docker, Flask, and React', 'https://testdriven.io/'),
        PBLTutorial('Build A Simple Web App With Flask', 'https://pythonspot.com/flask-web-app-with-python/'),
        PBLTutorial('Create A Django API in under 20 minutes', 'https://codeburst.io/create-a-django-api-in-under-20-minutes-2a082a60f6f3'),
        PBLTutorial('Build a Community-driven delivery application (2-part series)', 'https://www.ashwinhariharan.tech/blog/thinking-of-building-a-contact-tracing-application-heres-what-you-can-do-instead/'),
        PBLTutorial('Realtime Chat application with Vue, django-notifs, RabbitMQ (6-part series)', 'https://danidee10.github.io/2018/01/01/realtime-django-1.html'),
      ]),
      PBLSubCategory('Bots', [
        PBLTutorial('Build a Reddit Bot', 'http://pythonforengineers.com/build-a-reddit-bot-part-1/'),
        PBLTutorial('How to Make a Reddit Bot (video)', 'https://www.youtube.com/watch?v=krTUf7BpTc0'),
        PBLTutorial('Build a Facebook Messenger Bot', 'https://blog.hartleybrody.com/fb-messenger-bot/'),
        PBLTutorial('Making a Reddit + Facebook Messenger Bot', 'https://pythontips.com/2017/04/13/making-a-reddit-facebook-messenger-bot/'),
        PBLTutorial('How To Create a Telegram Bot Using Python (2-part series)', 'https://khashtamov.com/en/how-to-create-a-telegram-bot-using-python/'),
        PBLTutorial('Create a Twitter Bot In Python', 'https://medium.freecodecamp.org/creating-a-twitter-bot-in-python-with-tweepy-ac524157a607'),
      ]),
      PBLSubCategory('Data Science', [
        PBLTutorial('Learn Python For Data Science by Doing Several Projects (6-part video series)', 'https://www.youtube.com/watch?v=T5pRlIbr6gg'),
      ]),
      PBLSubCategory('Machine Learning', [
        PBLTutorial('Write Linear Regression From Scratch in Python (video)', 'https://www.youtube.com/watch?v=uwwWVAgJBcM'),
        PBLTutorial('Step-By-Step Machine Learning In Python', 'https://machinelearningmastery.com/machine-learning-in-python-step-by-step/'),
        PBLTutorial('Predict Quality Of Wine', 'https://medium.freecodecamp.org/using-machine-learning-to-predict-the-quality-of-wines-9e2e13d7480d'),
        PBLTutorial('Solving A Fruits Classification Problem', 'https://towardsdatascience.com/solving-a-simple-classification-problem-with-python-fruits-lovers-edition-d20ab6b071d2'),
        PBLTutorial('Learn Unsupervised Learning with Python', 'https://scikit-learn.org/stable/unsupervised_learning.html'),
        PBLTutorial('Build Your Own Neural Net from Scratch in Python', 'https://towardsdatascience.com/how-to-build-your-own-neural-network-from-scratch-in-python-68998a08e4f6'),
        PBLTutorial('Linear Regression without sklearn', 'https://medium.com/we-are-orb/linear-regression-in-python-without-scikit-learn-50aef4b8d122'),
        PBLTutorial('Multivariate Linear Regression without sklearn', 'https://medium.com/we-are-orb/multivariate-linear-regression-in-python-without-scikit-learn-7091b1d45905'),
        PBLTutorial('Music Recommender using KNN', 'https://towardsdatascience.com/how-to-build-a-simple-song-recommender-296fcbc8c85'),
        PBLTutorial('Find Similar Quora Questions - BOW, TFIDF, Xgboost', 'https://towardsdatascience.com/finding-similar-quora-questions-with-bow-tfidf-and-random-forest-c54ad88d1370'),
        PBLTutorial('Find Similar Quora Questions - Word2Vec and Xgboost', 'https://towardsdatascience.com/finding-similar-quora-questions-with-word2vec-and-xgboost-1a19ad272c0d'),
        PBLTutorial('Detecting Fake News with Python and Machine Learning', 'https://data-flair.training/blogs/advanced-python-project-detecting-fake-news/'),
      ]),
      PBLSubCategory('OpenCV', [
        PBLTutorial('Build A Document Scanner', 'https://www.pyimagesearch.com/2014/09/01/build-kick-ass-mobile-document-scanner-just-5-minutes/'),
        PBLTutorial('Build A Face Detector using OpenCV and Deep Learning', 'https://www.pyimagesearch.com/2018/02/26/face-detection-with-opencv-and-deep-learning/'),
        PBLTutorial('Build fastest custom object Detection system using YOLOv3 (video series)', 'https://www.youtube.com/playlist?list=PLKHYJbyeQ1a0oGzgRXy-QwAN1tSV4XZxg'),
        PBLTutorial('Build a Face Recognition System using OpenCV, Python and Deep Learning', 'https://www.pyimagesearch.com/2018/06/18/face-recognition-with-opencv-python-and-deep-learning/'),
        PBLTutorial('Detect The Salient Features in an Image', 'https://www.pyimagesearch.com/2018/07/16/opencv-saliency-detection/'),
        PBLTutorial('Build A Barcode Scanner', 'https://www.pyimagesearch.com/2018/05/21/an-opencv-barcode-and-qr-code-scanner-with-zbar/'),
        PBLTutorial('Learn Face Clustering with Python', 'https://www.pyimagesearch.com/2018/07/09/face-clustering-with-python/'),
        PBLTutorial('Object Tracking with Camshift', 'https://www.pyimagesearch.com/wp-content/uploads/2014/11/opencv_crash_course_camshift.pdf'),
        PBLTutorial('Semantic Segmentation with OpenCV and Deep Learning', 'https://www.pyimagesearch.com/2018/09/03/semantic-segmentation-with-opencv-and-deep-learning/'),
        PBLTutorial('Text Detection in Images and Videos', 'https://www.pyimagesearch.com/2018/08/20/opencv-text-detection-east-text-detector/'),
        PBLTutorial('People Counter using OpenCV', 'https://www.pyimagesearch.com/2018/08/13/opencv-people-counter/'),
        PBLTutorial('Tracking Multiple Objects with OpenCV', 'https://www.pyimagesearch.com/2018/08/06/tracking-multiple-objects-with-opencv/'),
        PBLTutorial('Neural Style Transfer with OpenCV', 'https://www.pyimagesearch.com/2018/08/27/neural-style-transfer-with-opencv/'),
        PBLTutorial('OpenCV OCR and Text Recognition', 'https://www.pyimagesearch.com/2018/09/17/opencv-ocr-and-text-recognition-with-tesseract/'),
        PBLTutorial('Text Skew Correction Tutorial', 'https://www.pyimagesearch.com/2017/02/20/text-skew-correction-opencv-python/'),
        PBLTutorial('Facial Landmark Detection Tutorial', 'https://www.pyimagesearch.com/2017/04/03/facial-landmarks-dlib-opencv-python/'),
        PBLTutorial('Object Detection using Mask-R-CNN', 'https://www.learnopencv.com/deep-learning-based-object-detection-and-instance-segmentation-using-mask-r-cnn-in-opencv-python-c/'),
        PBLTutorial('Automatic Target Detection Tutorial', 'https://www.pyimagesearch.com/2015/05/04/target-acquired-finding-targets-in-drone-and-quadcopter-video-streams-using-python-and-opencv/'),
        PBLTutorial('EigenFaces using OpenCV', 'https://www.learnopencv.com/eigenface-using-opencv-c-python/'),
        PBLTutorial('Faster(5-point) Facial Landmark Detection Tutorial', 'https://www.pyimagesearch.com/2018/04/02/faster-facial-landmark-detector-with-dlib/'),
        PBLTutorial('Hand Keypoint Detection', 'https://www.learnopencv.com/hand-keypoint-detection-using-deep-learning-and-opencv/'),
        PBLTutorial('Dlib Correlation Object Tracking - Single Object', 'https://www.pyimagesearch.com/2018/10/22/object-tracking-with-dlib/'),
        PBLTutorial('Dlib Correlation Object Tracking - Multiple Objects', 'https://www.pyimagesearch.com/2018/10/29/multi-object-tracking-with-dlib/'),
        PBLTutorial('Image Stitching with OpenCV and Python', 'https://www.pyimagesearch.com/2018/12/17/image-stitching-with-opencv-and-python/'),
        PBLTutorial('Instance Segmentation with OpenCV', 'https://www.pyimagesearch.com/2018/11/26/instance-segmentation-with-opencv/'),
        PBLTutorial('Face mask detector', 'https://www.pyimagesearch.com/2020/05/04/covid-19-face-mask-detector-with-opencv-keras-tensorflow-and-deep-learning/'),
      ]),
      PBLSubCategory('Deep Learning', [
        PBLTutorial('Using Convolutional Neural Nets to Detect Facial Keypoints', 'http://danielnouri.org/notes/2014/12/17/using-convolutional-neural-nets-to-detect-facial-keypoints-tutorial/'),
        PBLTutorial('Generate an Average Face using Python and OpenCV', 'https://www.learnopencv.com/average-face-opencv-c-python-tutorial/'),
        PBLTutorial('Break A Captcha System using CNNs', 'https://medium.com/@ageitgey/how-to-break-a-captcha-system-in-15-minutes-with-machine-learning-dbebb035a710'),
        PBLTutorial('Use pre-trained Inception model to provide image predictions', 'https://medium.com/google-cloud/keras-inception-v3-on-google-compute-engine-a54918b0058'),
        PBLTutorial('Create your first CNN', 'https://hackernoon.com/deep-learning-cnns-in-tensorflow-with-gpus-cba6efe0acc2'),
        PBLTutorial('Build A Facial Recognition Pipeline', 'https://hackernoon.com/building-a-facial-recognition-pipeline-with-deep-learning-in-tensorflow-66e7645015b8'),
        PBLTutorial('Build An Image Caption Generator', 'https://medium.freecodecamp.org/building-an-image-caption-generator-with-deep-learning-in-tensorflow-a142722e9b1f'),
        PBLTutorial('Make your Own Face Recognition System', 'https://medium.freecodecamp.org/making-your-own-face-recognition-system-29a8e728107c'),
        PBLTutorial('Train a Language Detection AI in 20 minutes', 'https://towardsdatascience.com/how-i-trained-a-language-detection-ai-in-20-minutes-with-a-97-accuracy-fdeca0fb7724'),
        PBLTutorial('Object Detection With Neural Networks', 'https://towardsdatascience.com/object-detection-with-neural-networks-a4e2c46b4491'),
        PBLTutorial('Learn Twitter Sentiment Analysis (11-part series)', 'https://towardsdatascience.com/another-twitter-sentiment-analysis-bb5b01ebad90'),
        PBLTutorial('Use Transfer Learning for custom image classification', 'https://becominghuman.ai/transfer-learning-retraining-inception-v3-for-custom-image-classification-2820f653c557'),
        PBLTutorial('Code a simple Neural Network in 11 lines of Python', 'https://iamtrask.github.io/2015/07/12/basic-python-network/'),
        PBLTutorial('Build a Neural Network using Gradient Descent Approach', 'https://iamtrask.github.io/2015/07/27/python-network-part2/'),
        PBLTutorial('Train a Keras Model To Generate Colors', 'https://heartbeat.fritz.ai/how-to-train-a-keras-model-to-generate-colors-3bc79e54971b'),
        PBLTutorial('Get Started with Keras on a Custom Dataset', 'https://www.pyimagesearch.com/2018/09/10/keras-tutorial-how-to-get-started-with-keras-deep-learning-and-python/'),
        PBLTutorial('Use EigenFaces and FisherFaces on Faces94 dataset', 'https://nicholastsmith.wordpress.com/2016/02/18/eigenfaces-versus-fisherfaces-on-the-faces94-database-with-scikit-learn/'),
        PBLTutorial('Kaggle MNIST Digit Recognizer Tutorial', 'https://medium.com/@lvarruda/how-to-get-top-2-position-on-kaggles-mnist-digit-recognizer-48185d80a2d4'),
        PBLTutorial('Fashion MNIST tutorial with tf.keras', 'https://medium.com/tensorflow/hello-deep-learning-fashion-mnist-with-keras-50fcff8cd74a'),
        PBLTutorial('CNN using Keras to automatically classify root health', 'https://www.pyimagesearch.com/2018/10/15/deep-learning-hydroponics-and-medical-marijuana/'),
        PBLTutorial('Keras vs Tensorflow', 'https://www.pyimagesearch.com/2018/10/08/keras-vs-tensorflow-which-one-is-better-and-which-one-should-i-learn/'),
        PBLTutorial('Deep Learning and Medical Image Analysis for Malaria Detection', 'https://www.pyimagesearch.com/2018/12/03/deep-learning-and-medical-image-analysis-with-keras/'),
        PBLTutorial('Transfer Learning for Image Classification using Keras', 'https://towardsdatascience.com/transfer-learning-for-image-classification-using-keras-c47ccf09c8c8'),
        PBLTutorial('Code a Smile Classifier using CNNS in Python', 'https://github.com/kylemcdonald/SmileCNN'),
        PBLTutorial('Natural Language Processing using scikit-learn', 'https://towardsdatascience.com/natural-language-processing-count-vectorization-with-scikit-learn-e7804269bb5e'),
        PBLTutorial('Code a Taylor Swift Lyrics Generator', 'https://towardsdatascience.com/ai-generates-taylor-swifts-song-lyrics-6fd92a03ef7e'),
        PBLTutorial('Mask detection using PyTorch Lightning', 'https://towardsdatascience.com/how-i-built-a-face-mask-detector-for-covid-19-using-pytorch-lightning-67eb3752fd61'),
      ]),
      PBLSubCategory('Miscellaneous', [
        PBLTutorial('Build a Simple Interpreter', 'https://ruslanspivak.com/lsbasi-part1/'),
        PBLTutorial('Build a Simple Blockchain in Python', 'https://hackernoon.com/learn-blockchains-by-building-one-117428612f46'),
        PBLTutorial('Write a NoSQL Database in Python', 'https://jeffknupp.com/blog/2014/09/01/what-is-a-nosql-database-learn-by-writing-one-in-python/'),
        PBLTutorial('Building a Gas Pump Scanner with OpenCV/Python/iOS', 'https://hackernoon.com/building-a-gas-pump-scanner-with-opencv-python-ios-116fe6c9ae8b'),
        PBLTutorial('Build a Distributed Streaming System with Python and Kafka', 'https://codequs.com/p/S14jQ5UyG/build-a-distributed-streaming-system-with-apache-kafka-and-python'),
        PBLTutorial('Writing a basic x86-64 JIT compiler from scratch in stock Python', 'https://csl.name/post/python-jit/'),
        PBLTutorial('Making a low level (Linux) debugger (2-part series)', 'https://blog.asrpo.com/making_a_low_level_debugger'),
        PBLTutorial('Implementing a Search Engine (3-part series)', 'http://www.ardendertat.com/2011/05/30/how-to-implement-a-search-engine-part-1-create-index/'),
        PBLTutorial('Build the Game of Life', 'https://robertheaton.com/2018/07/20/project-2-game-of-life/'),
        PBLTutorial('Create terminal ASCII art', 'https://robertheaton.com/2018/06/12/programming-projects-for-advanced-beginners-ascii-art/'),
        PBLTutorial('Write a Tic-Tac-Toe AI', 'https://robertheaton.com/2018/10/09/programming-projects-for-advanced-beginners-3-a/'),
        PBLTutorial('Create photomosaic art', 'https://robertheaton.com/2018/11/03/programming-project-4-photomosaics/'),
        PBLTutorial('Build the game "Snake" in the terminal', 'https://robertheaton.com/2018/12/02/programming-project-5-snake/'),
        PBLTutorial('Write yourself a Git', 'https://wyag.thb.lt/'),
        PBLTutorial('A Python implementation of a Python bytecode runner', 'https://www.aosabook.org/en/500L/a-python-interpreter-written-in-python.html'),
        PBLTutorial('Create a Voice assistant using Python', 'https://www.geeksforgeeks.org/voice-assistant-using-python/'),
      ]),
    ],
  ),

  // ── R ─────────────────────────────────────────────────────
  PBLLanguage(
    'R',
    Icons.bar_chart,
    Color(0xFF276DC3),
    [
      PBLSubCategory('General', [
        PBLTutorial('Build Web Apps with Shiny', 'http://shiny.rstudio.com/tutorial/'),
        PBLTutorial('Build A Cryptocurrency Bot', 'https://towardsdatascience.com/build-a-cryptocurrency-trading-bot-with-r-1445c429e1b1'),
        PBLTutorial('Learn Associate Rule Mining in R', 'https://towardsdatascience.com/association-rule-mining-in-r-ddf2d044ae50'),
      ]),
    ],
  ),

  // ── Ruby ──────────────────────────────────────────────────
  PBLLanguage(
    'Ruby',
    Icons.diamond,
    Color(0xFFCC342D),
    [
      PBLSubCategory('Core', [
        PBLTutorial('Build a Network Stack with Ruby', 'https://medium.com/geckoboard-under-the-hood/how-to-build-a-network-stack-in-ruby-f73aeb1b661b'),
        PBLTutorial('Build your own Redis (5-part series)', 'https://rohitpaulk.com/articles/redis-0'),
        PBLTutorial('Rebuilding Git in Ruby', 'https://thoughtbot.com/blog/rebuilding-git-in-ruby'),
      ]),
      PBLSubCategory('Ruby on Rails', [
        PBLTutorial('The Ruby on Rails Tutorial', 'https://www.railstutorial.org/book'),
        PBLTutorial('Build Instagram From Scratch with Ruby on Rails', 'https://www.dropbox.com/s/9vq430e9s3q7pu8/Let%27s%20Build%20Instagram%20with%20Ruby%20on%20Rails%20-%20Free%20Edition.pdf?dl=0'),
        PBLTutorial('Build a Social Network using Rails', 'https://medium.com/rails-ember-beyond/how-to-build-a-social-network-using-rails-eb31da569233'),
        PBLTutorial('How To Build a Ruby on Rails Application', 'https://www.digitalocean.com/community/tutorials/how-to-build-a-ruby-on-rails-application'),
      ]),
    ],
  ),

  // ── Rust ──────────────────────────────────────────────────
  PBLLanguage(
    'Rust',
    Icons.build,
    Color(0xFFDEA584),
    [
      PBLSubCategory('General', [
        PBLTutorial('A Simple Web App in Rust (3-part series)', 'http://joelmccracken.github.io/entries/a-simple-web-app-in-rust-pt-1/'),
        PBLTutorial('Write an OS in pure Rust', 'https://os.phil-opp.com/'),
        PBLTutorial('Build a browser engine in Rust', 'https://limpet.net/mbrubeck/2014/08/08/toy-layout-engine-1.html'),
        PBLTutorial('Write a Microservice in Rust', 'http://www.goldsborough.me/rust/web/tutorial/2018/01/20/17-01-11-writing_a_microservice_in_rust/'),
        PBLTutorial('Learning Rust with Too Many Linked Lists', 'http://cglab.ca/~abeinges/blah/too-many-lists/book/README.html'),
        PBLTutorial('Writing Scalable Chat Service from Scratch (2-part series)', 'https://nbaksalyar.github.io/2015/07/10/writing-chat-in-rust.html'),
        PBLTutorial('Writing a Rust Roguelike for the Desktop and the Web', 'https://aimlesslygoingforward.com/blog/2019/02/09/writing-a-rust-roguelike-for-the-desktop-and-the-web/'),
        PBLTutorial('Single Page Applications using Rust', 'http://www.sheshbabu.com/posts/rust-wasm-yew-single-page-application/'),
        PBLTutorial('Writing NES Emulator in Rust', 'https://bugzmanov.github.io/nes_ebook/'),
        PBLTutorial('Create a simulation of evolution (4-part series, WebAssembly)', 'https://pwy.io/en/posts/learning-to-fly-pt1/'),
      ]),
    ],
  ),

  // ── Scala ─────────────────────────────────────────────────
  PBLLanguage(
    'Scala',
    Icons.filter_vintage,
    Color(0xFFDC322F),
    [
      PBLSubCategory('General', [
        PBLTutorial('Simple actor-based blockchain', 'https://www.freecodecamp.org/news/how-to-build-a-simple-actor-based-blockchain-aac1e996c177/'),
        PBLTutorial('No Magic: Regular Expressions', 'https://rcoh.svbtle.com/no-magic-regular-expressions'),
      ]),
    ],
  ),

  // ── Swift ─────────────────────────────────────────────────
  PBLLanguage(
    'Swift',
    Icons.phone_iphone,
    Color(0xFFF05138),
    [
      PBLSubCategory('General', [
        PBLTutorial('Hacking with Swift - Learn Swift by doing 39 projects', 'https://www.hackingwithswift.com/read'),
        PBLTutorial('Retro first-person shooter from scratch', 'https://github.com/nicklockwood/RetroRampage'),
      ]),
    ],
  ),

  // ── Additional Resources ──────────────────────────────────
  PBLLanguage(
    'Additional Resources',
    Icons.library_books,
    Color(0xFF2E7D32),
    [
      PBLSubCategory('Learning Platforms', [
        PBLTutorial('React Redux Links', 'https://github.com/markerikson/react-redux-links'),
        PBLTutorial('Udemy', 'https://www.udemy.com/'),
        PBLTutorial('Full Stack Python', 'https://www.fullstackpython.com/'),
        PBLTutorial('Node School', 'https://nodeschool.io/'),
        PBLTutorial('ScotchIO', 'https://scotch.io/'),
        PBLTutorial('Exercism', 'http://www.exercism.io/'),
        PBLTutorial('Egghead.io', 'http://www.egghead.io/'),
        PBLTutorial('Michael Herman\'s Blog', 'http://mherman.org/'),
        PBLTutorial('Thinkster.io', 'http://thinkster.io'),
        PBLTutorial('Enlight', 'https://enlight.nyc/'),
        PBLTutorial('Hack Club Workshops', 'https://hackclub.com/workshops/'),
        PBLTutorial('CodeCrafters', 'https://codecrafters.io/'),
      ]),
    ],
  ),
];
