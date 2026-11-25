# Develop in Swift

<https://developer.apple.com/tutorials/develop-in-swift>

## App Design

### Prototypes

- You can mock up prototypes in Figma using the iOS and iPadOS 27 UI Kit
  [here](https://www.figma.com/community/file/1651309003795292092/ios-and-ipados-27).
- You can use the Icon Composer app to design your icons.

### Testing and Validation

- Design your tests to focus on one feature at a time.

### Iteration

- Custom components may not scale well with different sizes of dynamic type, so
  use custom components with care.

## Agentic Coding

- Starting with a detailed plan is a good way to kick it off. Remember /plan
  engages the agent in plan mode. Providing pictures or UI mockups can also be
  quite helpful. You can also provide the instruction “Ask me questions about
  the app before making decisions on your own.”

  ```text
  /plan

  Build an app that suggests micro adventures close to me with a pin on
  the map.

  I want to be able to narrow the suggestions by category and effort level
  required to complete them.

  I want to mark them as done when I complete them.

  I want to see the list of adventures that have been completed.

  Ask me questions about the app before making decisions on your own.

  Use the attached image as a guide for the user interface.

  Read the attached file named Categories and Efforts - Micro Adventures.rtf
  to determine the categories and effort levels I want in the filters.

  Read the Layout guidance in the Human Interface Guidelines
  (https://developer.apple.com/design/human-interface-guidelines/layout)
  to guide the app's layout.
  ```

- You can then exiting planning mode with /exit-plan then ask the Agent to
  "Create a PLAN.md file with the plan and add it to my Xcode project.". If you
  make changes to the PLAN.md file, instruct the agent to "Read the PLAN.md file
  to consider the changes I've just made." Once the plan is ready for action,
  simply tell the agent to "Implement the plan." When the coding agent finishes
  writing the code for your app, choose an iPhone simulator from the run
  destination menu in the toolbar. Then click the Run button or press Command-R
  to run your app. After interacting with the application, have the agent make
  follow up changes with the prompt:

  ```text
  Read the following notes with the changes I want to make. Ask me questions,
  create tasks, and once I approve them all, implement them.

  <your notes here>
  ```

- If you're not sure how you want to fix something, you can prompt the agent for
  options: "Give me options for presenting the adventure card, such as keeping
  it over the map or showing it as a callout above its pin. Explain the pros and
  cons of each."
- You can use prompts to test different settings with your app:
  - "Add a preview of the adventure card in Dark Mode."
  - "Make sure the adventure card supports Dynamic Type, and add a preview at
    the largest accessibility text size."
  - "Audit my app for accessibility issues, such as missing VoiceOver labels,
    text that doesn't adapt to larger sizes, and information shown only by
    color. List what you find before you fix anything."
  - "Translate my app into <language>."
- Be specific about what to test when prompting the agent to create tests.

  ```text
  Create tests that verify the app's core features:

  - Filtering by category and effort level shows only matching adventures.
  - Tapping Next adventure shows a different adventure that matches the filters.
  - Marking an adventure as done adds it to the completed list.
  - Completed adventures are still there after the app relaunches.
  ```

- You can also ask it to add an accessibility audit to your tests, so every test
  run checks for new accessibility issues. Click the Navigators button, then
  Tests, or press Command-6 to see all the tests created for your project.

## SwiftUI

- Use Shift+Cmd+L for quick access to the snippet library or do View->Show
  Library.
