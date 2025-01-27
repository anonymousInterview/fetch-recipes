### Summary: Include screen shots or a video of your app highlighting its features

👋 Welcome to the FetchRecipes app. The FetchRecipes app features:
- A list of recipes
- Pull to refresh list functionality
- Functional error and empty states
- Accessibility as a first class citizen: voice over, dynamic type, appropriate tap targets, and dark mode
 
| Default | Empty State | Error State |
|-|-|-|
|![Default](/screenshots/default.png "Default")|![Empty](/screenshots/empty.png "Empty")|![Error](/screenshots/error.png "Error")|

| Pull to Refresh | Dynamic Type | Code Coverage |
|-|-|-|
|![Refresh](/screenshots/refresh.png "Refresh")|![Dynamic Type](/screenshots/dynamic_type.png "Dynamic Type")|![Code Coverage](/screenshots/coverage.png "Code Coverage")|

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
 
#### Modularization
Modularization enforces separation of responsibilities. I've created two modules:
Recipes and Networking. The Recipes feature module holds domain knowledge 
over everything recipe related. From services to views, it knows how to display
a recipe list. The Recipe module depends on the foundational Networking module. 
The networking module owns the networking layer. This includes caching and 
an HTTP Client. It also includes an asynchronous image loader accompanied with a view
that implements the loader. The Recipe module is able to depend on the Networking
module for all of its networking needs, without knowing any implementation details.
We're able to do this through protocol interfaces (e.g. HTTPClient).

#### Efficient Network Usage
One of the take-home requirements was efficient network usage. I've built a small
data caching system that supports both in-memory and disk retrieval of images.
Respecting a user's device is a huge priority when building consumer applications,
so the cache has a size limit and evicts data when it is full. The cache does this
through a Least Recently Used (LRU) caching policy. Keeping an on disk cache up to
date with an in memory cache can require a lot of writing to disk. To minimize
writes, we debounce the requests. This allows us to batch updates to our
on-disk store.

#### Dependency Injection
Our modules allow us to easily define functional boundaries and dependencies. This
is exemplified in `FetchRecipesApp`. The app imports a few dependencies and
instantiates the `RecipesView`. All dependencies are explicitly defined and injected.
These dependencies have protocol interfaces that allow us to extract
implementation details. Using these interfaces increases testability by allowing
us to mock dependencies easily.

#### Accessibility
Consumer applications should maintain high accessibility standards 
(such as WCAG 2.2). In this project, I've prioritized voice over, dynamic type, 
appropriately sized tap targets, and dark mode.

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

I spent ~12 hours on this project.

- 6: Image Caching
- 2: UI
- 3: Testing
- 1: Documentation

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

When building the image caching solution, I prioritized minimizing network traffic.
The quickest retrieval of an image happens when the image is already in-memory.
That being said, the take-home requirement specified storing to disk. Additionally,
if we want to persist images across app launches, we would need to 
persist to disk anyways.

This led me down the path of building a `DefaultDataCache` that relies on 
its in-memory store for data retrieval. Using a key:value store for this 
gave us constant (O(1)) retrieval time. With this implementation, a user
can scroll through `RecipesView` and fetch each image for a given Recipe 
from network only once. Ah, but what about persisting across app launches?
Let's talk about our disk store... 

To persist across app launches, we need to store a version of our in-memory
cache on-disk and keep it up to date. We start the on-disk caching process
by updating our on-disk cache every time we update our in-memory cache. As 
a user scrolls through the recipe list, we're updating our in-memory
cache as well as the on-disk cache. This base strategy leads to many disk writes
which can cause performance issues. In general, we'd like to minimize writes
to disk. To do this, I built a simple debouncer to batch disk writes. By 
debouncing requests, I was able to significantly reduce the amount of writes. If you
build and run the application locally, you'll be able to see a log of cache hits
and disk writes. You'll see that even though we are rapidly updating our in-memory
cache, writing to disk is much more infrequent. Once the app is deallocated and
the user boots up the app again, we load the existing on-disk cache back into 
memory on the initialization of our cache (`DefaultDataCache`). 

### Weakest Part of the Project: What do you think is the weakest part of your project?

When building a production grade app, you must decide what architecture
to build the app with. In this app, I've used a MVVM approach. Given
there wasn't any navigational requirements, I didn't setup a
routing system. In other apps, I've used the Coordinator pattern to extract 
routing logic from the view layer. Recent codebases I've worked on have
been built with a hybrid UIKit + SwiftUI view layer. They have Coordinators
that manage navigation through UINavigationControllers. It'd be interesting
to explore the Coordinator pattern using a SwiftUI NavigationStack.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.

This was a fun project. Thanks for the exercise.
