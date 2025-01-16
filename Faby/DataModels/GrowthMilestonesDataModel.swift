import Foundation
class GrowthMilestonesDataModel {
    static let shared = GrowthMilestonesDataModel()
    var milestones: [GrowthMilestone] = [
        // MARK: - 12 months
        //Social
        GrowthMilestone(
            title: "Plays Interactive Games",
            query: "Does your child play games like pat-a-cake with you?",
            image: "pat_a_cake_image",
            milestoneMonth: .month12,
            description: "Playing games like pat-a-cake fosters social interaction and bonding while teaching turn-taking and basic hand coordination.",
            category: .social
        ),
            
        //Language
        GrowthMilestone(
            title: "Waves Bye-Bye",
            query: "Does your child wave 'bye-bye'?",
            image: "waves_bye_image",
            milestoneMonth: .month12,
            description: "Waving bye-bye shows your child is learning social gestures and how to communicate nonverbally, an important step in interaction.",
            category: .language
        ),
        GrowthMilestone(
            title: "Calls Parent by Name",
            query: "Does your child call a parent 'mama' or 'dada' or another special name?",
            image: "calls_parent_image",
            milestoneMonth: .month12,
            description: "Using specific words like 'mama' or 'dada' demonstrates growing language skills and emotional connection to caregivers.",
            category: .language
        ),
        GrowthMilestone(
            title: "Understands 'No'",
            query: "Does your child pause or stop briefly when you say 'no'?",
            image: "understands_no_image",
            milestoneMonth: .month12,
            description: "Understanding 'no' reflects your child’s ability to process and respond to simple commands, a foundation for discipline and safety awareness.",
            category: .language
        ),

        //Cognitive
        GrowthMilestone(
            title: "Puts Objects in Containers",
            query: "Does your child put something in a container, like a block in a cup?",
            image: "puts_in_container_image",
            milestoneMonth: .month12,
            description: "Putting objects in containers shows problem-solving skills, hand-eye coordination, and an understanding of cause-and-effect.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Searches for Hidden Items",
            query: "Does your child look for things you hide, like a toy under a blanket?",
            image: "searches_hidden_items_image",
            milestoneMonth: .month12,
            description: "Looking for hidden objects demonstrates your child’s memory and understanding of object permanence, an important cognitive milestone.",
            category: .cognitive
        ),

        //Physical
        GrowthMilestone(
            title: "Pulls to Stand",
            query: "Does your child pull up to stand?",
            image: "pulls_to_stand_image",
            milestoneMonth: .month12,
            description: "Pulling up to stand indicates strengthening leg muscles and developing balance, key steps toward independent walking.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Cruises Along Furniture",
            query: "Does your child walk while holding on to furniture?",
            image: "cruises_along_furniture_image",
            milestoneMonth: .month12,
            description: "Walking while holding furniture helps build confidence and coordination, preparing your child for walking independently.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Drinks from Cup You Hold",
            query: "Does your child drink from a cup without a lid, as you hold it?",
            image: "drinks_from_cup_image",
            milestoneMonth: .month12,
            description: "Drinking from a cup introduces self-feeding skills and strengthens oral coordination, which is important for eating and speaking.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Picks Up Small Objects",
            query: "Does your child pick up small objects between their thumb and pointer finger?",
            image: "picks_up_small_objects_image",
            milestoneMonth: .month12,
            description: "Picking up small objects using the thumb and pointer finger is a sign of developing fine motor skills and hand control, critical for self-feeding and play.",
            category: .physical
        ),
        
        // MARK: - 15 months
        //Social
        GrowthMilestone(
        title: "Imitates Play",
            query: "Does your child copy others during play?",
            image: "imitates_play_image",
            milestoneMonth: .month15,
            description: "At 15 months, children often mimic others' actions during play, like taking toys out of a container. This shows their growing awareness of social interactions and their ability to learn by observing.",
            category: .social
        ),
        GrowthMilestone(
            title: "Shows Objects",
            query: "Does your child show you objects they like?",
            image: "shows_objects_image",
            milestoneMonth: .month15,
            description: "Your child may begin showing you objects they find interesting, which reflects their desire to share experiences and communicate their preferences, an important step in building social connections.",
            category: .social
        ),
        GrowthMilestone(
            title: "Claps When Excited",
            query: "Does your child clap when excited?",
            image: "clapping_image",
            milestoneMonth: .month15,
            description: "Clapping when excited is an early sign of emotional expression and social engagement, helping your child connect their feelings to actions.",
            category: .social
        ),
        GrowthMilestone(
            title: "Hugs a Toy",
            query: "Does your child hug stuffed toys or dolls?",
            image: "hugs_toy_image",
            milestoneMonth: .month15,
            description: "Hugging a stuffed toy reflects your child’s growing ability to express affection and empathy, laying the foundation for meaningful relationships later in life.",
            category: .social
        ),
        GrowthMilestone(
            title: "Shows Affection",
            query: "Does your child show affection, like hugging or cuddling?",
            image: "shows_affection_image",
            milestoneMonth: .month15,
            description: "Displaying affection through hugs or cuddles is an important milestone in emotional development, showing your child is forming secure bondswith caregivers.",
            category: .social
        ),

        //Language
        GrowthMilestone(
            title: "Tries New Words",
            query: "Does your child try to say one or two words besides 'mama' or 'dada'?",
            image: "tries_words_image",
            milestoneMonth: .month15,
            description: "At this stage, your child may try to say simple words like 'ba' for ball. This shows progress in language development and their ability to communicate their needs.",
            category: .language
        ),
        GrowthMilestone(
            title: "Recognizes Named Objects",
            query: "Does your child look at familiar objects when named?",
            image: "recognizes_objects_image",
            milestoneMonth: .month15,
            description: "Recognizing objects by name demonstrates your child’s growing vocabulary and understanding of language, which are key to effective communication.",
            category: .language
        ),
        GrowthMilestone(
            title: "Follows Directions with Gestures",
            query: "Does your child follow directions that involve gestures and words?",
            image: "follows_gestures_image",
            milestoneMonth: .month15,
            description: "Following instructions paired with gestures shows your child’s ability to understand and process both verbal and nonverbal cues, an important skill for learning.",
            category: .language
        ),
        GrowthMilestone(
            title: "Points for Help",
            query: "Does your child point to ask for something or to get help?",
            image: "points_for_help_image",
            milestoneMonth: .month15,
            description: "Pointing to ask for help demonstrates problem-solving and the ability to seek assistance, essential skills for effective communication and independence.",
            category: .language
        ),
        
        //Cognitive
        GrowthMilestone(
            title: "Uses Objects Correctly",
            query: "Does your child try to use things the right way, like a phone, cup, or book?",
            image: "uses_objects_image",
            milestoneMonth: .month15,
            description: "Using objects correctly, like pretending to drink from a cup, reflects your child’s understanding of how things work and their ability to imitate everyday actions.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Stacks Objects",
            query: "Does your child stack at least two small objects, like blocks?",
            image: "stacks_objects_image",
            milestoneMonth: .month15,
            description: "Stacking objects shows developing hand-eye coordination, fine motor skills, and the ability to solve simple problems through experimentation.",
            category: .cognitive
        ),
        
        //Physical
        GrowthMilestone(
            title: "Takes Steps Independently",
            query: "Does your child take a few steps on their own?",
            image: "takes_steps_image",
            milestoneMonth: .month15,
            description: "Walking independently is a major physical milestone that indicates strengthening muscles and balance, key to mobility and exploration.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Feeds with Fingers",
            query: "Does your child use their fingers to feed themselves some food?",
            image: "feeds_with_fingers_image",
            milestoneMonth: .month15,
            description: "Using fingers to self-feed shows your child’s growing independence, fine motor skills, and ability to coordinate movements for practical tasks.",
            category: .physical
        ),
        
        // MARK: - 18 months
        //Social
        GrowthMilestone(
            title: "Explores but Checks for You",
            query: "Does your child move away from you but look back to make sure you’re close by?",
            image: "explores_checks_image",
            milestoneMonth: .month18,
            description: "This milestone shows your child is developing independence while maintaining a sense of security by checking in with you.",
            category: .social
        ),
        GrowthMilestone(
            title: "Points to Show Interest",
            query: "Does your child point to show you something interesting?",
            image: "points_interest_image",
            milestoneMonth: .month18,
            description: "Pointing to show interest indicates your child is learning to share experiences and communicate nonverbally, which is important for social and language development.",
            category: .social
        ),
        GrowthMilestone(
            title: "Wants Hands Washed",
            query: "Does your child put their hands out for you to wash them?",
            image: "hands_washed_image",
            milestoneMonth: .month18,
            description: "Wanting their hands washed reflects growing self-awareness and the beginning of learning hygiene habits.",
            category: .social
        ),
        GrowthMilestone(
            title: "Looks at Book Pages",
            query: "Does your child look at a few pages in a book with you?",
            image: "looks_book_image",
            milestoneMonth: .month18,
            description: "Looking at book pages encourages bonding and helps develop focus, curiosity, and early literacy skills.",
            category: .social
        ),
        GrowthMilestone(
            title: "Helps with Dressing",
            query: "Does your child help you dress them by pushing an arm through a sleeve or lifting a foot?",
            image: "helps_dressing_image",
            milestoneMonth: .month18,
            description: "Helping with dressing shows your child is developing coordination, awareness of routines, and a sense of independence.",
            category: .social
        ),
        
        //Language
        GrowthMilestone(
            title: "Says Three or More Words",
            query: "Does your child try to say three or more words besides 'mama' or 'dada'?",
            image: "three_words_image",
            milestoneMonth: .month18,
            description: "Using additional words demonstrates expanding vocabulary and language development, a key foundation for communication.",
            category: .language
        ),
        GrowthMilestone(
            title: "Follows One-Step Directions",
            query: "Does your child follow one-step directions without gestures, like 'Give it to me'?",
            image: "one_step_directions_image",
            milestoneMonth: .month18,
            description: "Following simple directions shows your child is developing comprehension and the ability to process verbal instructions.",
            category: .language
        ),
        
        //Cognitive
        GrowthMilestone(
            title: "Copies Chores",
            query: "Does your child copy you doing chores, like sweeping with a broom?",
            image: "copies_chores_image",
            milestoneMonth: .month18,
            description: "Imitating chores reflects learning through observation and shows your child is beginning to understand daily routines.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Plays Simply with Toys",
            query: "Does your child play with toys in a simple way, like pushing a toy car?",
            image: "simple_toy_play_image",
            milestoneMonth: .month18,
            description: "Playing with toys in simple ways shows your child is learning cause-and-effect and developing early problem-solving skills.",
            category: .cognitive
        ),
        
        //Physical
        GrowthMilestone(
            title: "Walks Without Help",
            query: "Does your child walk without holding on to anyone or anything?",
            image: "walks_without_help_image",
            milestoneMonth: .month18,
            description: "Walking independently is a major physical milestone that builds confidence and allows your child to explore more freely.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Scribbles",
            query: "Does your child scribble?",
            image: "scribbles_image",
            milestoneMonth: .month18,
            description: "Scribbling helps develop fine motor skills, hand-eye coordination, and creativity, paving the way for writing skills.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Drinks from a Cup Without Lid",
            query: "Does your child drink from a cup without a lid, even if they sometimes spill?",
            image: "drinks_without_lid_image",
            milestoneMonth: .month18,
            description: "Drinking from a lidless cup builds oral coordination and self-feeding skills, promoting independence.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Feeds Self with Fingers",
            query: "Does your child feed themselves with their fingers?",
            image: "feeds_self_fingers_image",
            milestoneMonth: .month18,
            description: "Self-feeding with fingers shows fine motor skill development and growing independence during mealtime.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Tries to Use a Spoon",
            query: "Does your child try to use a spoon?",
            image: "uses_spoon_image",
            milestoneMonth: .month18,
            description: "Using a spoon develops hand-eye coordination and self-feeding skills, an important step toward eating independently.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Climbs on and Off Furniture",
            query: "Does your child climb on and off a couch or chair without help?",
            image: "climbs_furniture_image",
            milestoneMonth: .month18,
            description: "Climbing furniture independently shows improved motor planning, strength, and balance.",
            category: .physical
        ),
        
        // MARK: - 24 months
        //Social
        GrowthMilestone(
            title: "Notices When Others Are Upset",
            query: "Does your child pause or look sad when someone is crying?",
            image: "notices_upset_image",
            milestoneMonth: .month24,
            description: "Noticing when others are upset shows early development of empathy and emotional awareness.",
            category: .social
        ),
        GrowthMilestone(
            title: "Looks to Your Face for Reactions",
            query: "Does your child look at your face to see how to react in a new situation?",
            image: "looks_for_reaction_image",
            milestoneMonth: .month24,
            description: "Looking at your face for guidance reflects growing social awareness and trust in your reactions to unfamiliar events.",
            category: .social
        ),
        
        //Language
        GrowthMilestone(
            title: "Points to Items in a Book",
            query: "Does your child point to things in a book when you ask, like 'Where is the bear?'?",
            image: "points_in_book_image",
            milestoneMonth: .month24,
            description: "Pointing to items in a book demonstrates listening skills, comprehension, and early language development.",
            category: .language
        ),
        GrowthMilestone(
            title: "Says Two Words Together",
            query: "Does your child say at least two words together, like 'More milk'?",
            image: "two_words_image",
            milestoneMonth: .month24,
            description: "Combining words marks a significant step in language development, showing an ability to form simple sentences.",
            category: .language
        ),
        GrowthMilestone(
            title: "Points to Body Parts",
            query: "Does your child point to at least two body parts when you ask them to show you?",
            image: "points_body_parts_image",
            milestoneMonth: .month24,
            description: "Pointing to body parts shows your child is learning vocabulary and connecting words with physical concepts.",
            category: .language
        ),
        GrowthMilestone(
            title: "Uses More Gestures",
            query: "Does your child use more gestures, like blowing a kiss or nodding yes, besides waving and pointing?",
            image: "uses_gestures_image",
            milestoneMonth: .month24,
            description: "Using gestures like blowing kisses or nodding reflects growing communication skills and nonverbal understanding.",
            category: .language
        ),
        
        //Cognitive
        GrowthMilestone(
            title: "Uses Both Hands",
            query: "Does your child hold something in one hand while using the other hand, like holding a container and taking the lid off?",
            image: "uses_both_hands_image",
            milestoneMonth: .month24,
            description: "Using both hands simultaneously demonstrates advanced coordination and problem-solving skills.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Tries Switches, Knobs, and Buttons",
            query: "Does your child try to use switches, knobs, or buttons on a toy?",
            image: "tries_switches_image",
            milestoneMonth: .month24,
            description: "Exploring switches, knobs, and buttons shows curiosity and the ability to understand cause-and-effect relationships.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Plays with Multiple Toys Together",
            query: "Does your child play with more than one toy at the same time, like putting toy food on a toy plate?",
            image: "plays_with_multiple_toys_image",
            milestoneMonth: .month24,
            description: "Playing with multiple toys together reflects growing imagination and the ability to combine actions in play.",
            category: .cognitive
        ),
        
        //Physical
        GrowthMilestone(
            title: "Kicks a Ball",
            query: "Does your child kick a ball?",
            image: "kicks_ball_image",
            milestoneMonth: .month24,
            description: "Kicking a ball shows improved coordination, leg strength, and balance.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Runs",
            query: "Does your child run?",
            image: "runs_image",
            milestoneMonth: .month24,
            description: "Running is a key milestone that reflects growing confidence, strength, and physical independence.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Walks Up Stairs",
            query: "Does your child walk (not climb) up a few stairs with or without help?",
            image: "walks_up_stairs_image",
            milestoneMonth: .month24,
            description: "Walking up stairs independently showcases improved balance, strength, and motor planning.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Eats with a Spoon",
            query: "Does your child eat with a spoon?",
            image: "eats_with_spoon_image",
            milestoneMonth: .month24,
            description: "Eating with a spoon demonstrates fine motor skills, hand-eye coordination, and growing independence during meals.",
            category: .physical
        ),
        
        // MARK: - 30 months
        //Social
        GrowthMilestone(
            title: "Plays Next to or With Other Children",
            query: "Does your child play next to other children and sometimes join them?",
            image: "plays_with_others_image",
            milestoneMonth: .month30,
            description: "Playing alongside or with other children demonstrates the development of social interaction and cooperation skills.",
            category: .social
        ),
        GrowthMilestone(
            title: "Shows What She Can Do",
            query: "Does your child show you what she can do by saying, 'Look at me!'?",
            image: "shows_what_can_do_image",
            milestoneMonth: .month30,
            description: "Showing off skills reflects growing confidence, self-awareness, and the desire for recognition from caregivers.",
            category: .social
        ),
        GrowthMilestone(
            title: "Follows Simple Routines",
            query: "Does your child follow simple routines like helping to pick up toys when you say, 'It’s clean-up time'?",
            image: "follows_routines_image",
            milestoneMonth: .month30,
            description: "Following routines demonstrates understanding of instructions and participation in structured activities.",
            category: .social
        ),
        
        //Language
        GrowthMilestone(
            title: "Says About 50 Words",
            query: "Does your child say around 50 words?",
            image: "says_50_words_image",
            milestoneMonth: .month30,
            description: "Having a vocabulary of about 50 words reflects significant language development and the ability to express basic needs and thoughts.",
            category: .language
        ),
        GrowthMilestone(
            title: "Uses Two or More Words With an Action Word",
            query: "Does your child say two or more words with an action word, like 'Doggie run'?",
            image: "action_words_image",
            milestoneMonth: .month30,
            description: "Combining words with an action word shows an understanding of sentence structure and expanding communication skills.",
            category: .language
        ),
        GrowthMilestone(
            title: "Names Things in a Book",
            query: "Does your child name things in a book when you point and ask, 'What is this?'?",
            image: "names_things_book_image",
            milestoneMonth: .month30,
            description: "Naming items in a book reflects language comprehension and the ability to associate words with images.",
            category: .language
        ),
        GrowthMilestone(
            title: "Uses Words Like 'I,' 'Me,' or 'We'",
            query: "Does your child use words like 'I,' 'me,' or 'we'?",
            image: "uses_pronouns_image",
            milestoneMonth: .month30,
            description: "Using pronouns demonstrates growing self-awareness and mastery of more complex aspects of language.",
            category: .language
        ),
        
        //Cognitive
        GrowthMilestone(
            title: "Pretends With Toys",
            query: "Does your child pretend, like feeding a block to a doll as if it were food?",
            image: "pretends_with_toys_image",
            milestoneMonth: .month30,
            description: "Pretend play shows creativity and the ability to use imagination to represent real-life scenarios.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Shows Problem-Solving Skills",
            query: "Does your child solve simple problems, like standing on a stool to reach something?",
            image: "problem_solving_image",
            milestoneMonth: .month30,
            description: "Problem-solving skills reflect the ability to think critically and find solutions to everyday challenges.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Follows Two-Step Instructions",
            query: "Does your child follow two-step instructions like, 'Put the toy down and close the door'?",
            image: "two_step_instructions_image",
            milestoneMonth: .month30,
            description: "Following two-step instructions demonstrates comprehension and the ability to process sequential tasks.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Identifies Colors",
            query: "Does your child point to a color, like red, when you ask, 'Which one is red?'?",
            image: "identifies_colors_image",
            milestoneMonth: .month30,
            description: "Recognizing colors reflects cognitive development, memory, and the ability to classify objects.",
            category: .cognitive
        ),
        
        
        //Physical
        GrowthMilestone(
            title: "Twists Doorknobs or Unscrews Lids",
            query: "Does your child twist things like doorknobs or unscrew lids?",
            image: "twists_doorknobs_image",
            milestoneMonth: .month30,
            description: "Twisting objects demonstrates improved fine motor skills and hand strength.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Takes Off Some Clothes",
            query: "Does your child take off some clothes by himself, like loose pants or an open jacket?",
            image: "takes_off_clothes_image",
            milestoneMonth: .month30,
            description: "Removing clothing independently shows growing motor skills and self-help abilities.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Jumps Off the Ground With Both Feet",
            query: "Does your child jump off the ground with both feet?",
            image: "jumps_with_both_feet_image",
            milestoneMonth: .month30,
            description: "Jumping with both feet reflects advanced coordination, balance, and leg strength.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Turns Book Pages One at a Time",
            query: "Does your child turn book pages one at a time when you read to her?",
            image: "turns_book_pages_image",
            milestoneMonth: .month30,
            description: "Turning book pages demonstrates fine motor skills, hand-eye coordination, and interest in reading activities.",
            category: .physical
        ),
        
        // MARK: - 36 months
        //Social
        GrowthMilestone(
            title: "Calms Down After Separation",
            query: "Does your child calm down within 10 minutes after you leave her, like at a childcare drop-off?",
            image: "calms_down_image",
            milestoneMonth: .month36,
            description: "Calming down after separation indicates emotional regulation and secure attachment to caregivers.",
            category: .social
        ),
        GrowthMilestone(
            title: "Joins Other Children to Play",
            query: "Does your child notice other children and join them to play?",
            image: "joins_children_to_play_image",
            milestoneMonth: .month36,
            description: "Playing with others reflects growing social skills, cooperation, and understanding of group dynamics.",
            category: .social
        ),
        
        //Language
        
        GrowthMilestone(
            title: "Engages in Conversation",
            query: "Does your child talk with you in conversation using at least two back-and-forth exchanges?",
            image: "engages_in_conversation_image",
            milestoneMonth: .month36,
            description: "Engaging in conversations shows advanced language skills and the ability to maintain a dialogue.",
            category: .language
        ),
        GrowthMilestone(
            title: "Asks 'Who,' 'What,' 'Where,' or 'Why' Questions",
            query: "Does your child ask questions like 'Who,' 'What,' 'Where,' or 'Why,' such as 'Where is mommy/daddy?'?",
            image: "asks_questions_image",
            milestoneMonth: .month36,
            description: "Asking questions reflects curiosity, cognitive growth, and developing language complexity.",
            category: .language
        ),
        GrowthMilestone(
            title: "Describes Actions in Pictures",
            query: "Does your child say what action is happening in a picture or book when asked, like 'running,' 'eating,' or 'playing'?",
            image: "describes_actions_image",
            milestoneMonth: .month36,
            description: "Describing actions in pictures shows understanding of verbs and the ability to connect language with visuals.",
            category: .language
        ),
        GrowthMilestone(
            title: "Says First Name",
            query: "Does your child say her first name when asked?",
            image: "says_first_name_image",
            milestoneMonth: .month36,
            description: "Saying their first name indicates self-awareness and familiarity with personal identity.",
            category: .language
        ),
        GrowthMilestone(
            title: "Speaks Clearly Most of the Time",
            query: "Does your child talk well enough for others to understand, most of the time?",
            image: "speaks_clearly_image",
            milestoneMonth: .month36,
            description: "Speaking clearly demonstrates advanced articulation and confidence in communication.",
            category: .language
        ),
        
        // Cognitive Milestones
        GrowthMilestone(
            title: "Draws a Circle",
            query: "Does your child draw a circle when you show him how?",
            image: "draws_circle_image",
            milestoneMonth: .month36,
            description: "Drawing a circle shows fine motor skills and the ability to follow visual instructions.",
            category: .cognitive
        ),
        GrowthMilestone(
            title: "Avoids Touching Hot Objects",
            query: "Does your child avoid touching hot objects, like a stove, when you warn her?",
            image: "avoids_hot_objects_image",
            milestoneMonth: .month36,
            description: "Avoiding hot objects indicates understanding of danger and the ability to follow safety instructions.",
            category: .cognitive
        ),
        
        //Movement/Physical Development Milestones
        GrowthMilestone(
            title: "Strings Items Together",
            query: "Does your child string items together, like large beads or macaroni?",
            image: "strings_items_image",
            milestoneMonth: .month36,
            description: "Stringing items demonstrates fine motor control, hand-eye coordination, and patience.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Puts On Some Clothes",
            query: "Does your child put on some clothes by himself, like loose pants or a jacket?",
            image: "puts_on_clothes_image",
            milestoneMonth: .month36,
            description: "Dressing independently shows growing self-help skills and coordination.",
            category: .physical
        ),
        GrowthMilestone(
            title: "Uses a Fork",
            query: "Does your child use a fork to eat?",
            image: "uses_fork_image",
            milestoneMonth: .month36,
            description: "Using a fork reflects fine motor skill development and progress in self-feeding abilities.",
            category: .physical
        )
    ]
    func milestones(forCategory category: GrowthCategory, andMonth month: MilestoneMonth) -> [GrowthMilestone] {
        return milestones.filter { $0.category == category && $0.milestoneMonth == month }
    }
        
    func milestones(forCategory category: GrowthCategory) -> [GrowthMilestone] {
        return milestones.filter { $0.category == category }
    }
        
    func milestones(forMonth month: MilestoneMonth) -> [GrowthMilestone] {
        return milestones.filter { $0.milestoneMonth == month }
    }
//    private init() {
//        milestones = [
//            
//
//    }
    
}
