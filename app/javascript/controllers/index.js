import { application } from "./application"

import SubscriberCountController from "./subscriber_count_controller"
application.register("subscriber-count", SubscriberCountController)

import ScrollRevealController from "./scroll_reveal_controller"
application.register("scroll-reveal", ScrollRevealController)
