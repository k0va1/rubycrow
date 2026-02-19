import { application } from "./application"

import SubscriberCountController from "./subscriber_count_controller"
application.register("subscriber-count", SubscriberCountController)

import ScrollRevealController from "./scroll_reveal_controller"
application.register("scroll-reveal", ScrollRevealController)

import LiveFeedController from "./live_feed_controller"
application.register("live-feed", LiveFeedController)

import CounterAnimationController from "./counter_animation_controller"
application.register("counter-animation", CounterAnimationController)

import NavbarController from "./navbar_controller"
application.register("navbar", NavbarController)

import ThemeController from "./theme_controller"
application.register("theme", ThemeController)

import AdminThemeController from "./admin_theme_controller"
application.register("admin-theme", AdminThemeController)
