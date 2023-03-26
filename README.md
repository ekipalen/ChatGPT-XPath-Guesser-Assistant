# Robocorp Assistant - ChatGPT Html Selector Guesser

This robot uses RPA.Assistant and RPA.OpenAI libraries to create XPath selectors for `Input` and/or `Button` web elements.

This Assistant Robot:

- Asks url where to search for the elements.
- Gets all the matching elements.
- Uses ChatGPT to create `XPath` locators and give them good names.
- Tests if the selectors can find elements from the website.
- If incorrect selectors are found robot can continue the conversation with ChatGPT and ask for a fix for the non working selectors.
- Creates a json file to the `output` folder and displays the content to the user.

![XPath_Guesser](https://user-images.githubusercontent.com/84192057/227776612-f4af71a2-0073-4d25-b5d9-919874bb3e12.png)

## Learning materials

- [Robocorp Developer Training Courses](https://robocorp.com/docs/courses)
- [Documentation links on Robot Framework](https://robocorp.com/docs/languages-and-frameworks/robot-framework)
- [Example bots in Robocorp Portal](https://robocorp.com/portal)
