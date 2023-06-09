DROP DATABASE IF EXISTS FitTrack;

CREATE DATABASE FitTrack;

USE FitTrack;

CREATE TABLE USER (
    USER_ID         SERIAL,
    USER_FIRST_NAME VARCHAR(32) NOT NULL,
    USER_LAST_NAME  VARCHAR(32) NOT NULL,
    USER_EMAIL      VARCHAR(256) NOT NULL UNIQUE CHECK (USER_EMAIL REGEXP '^[A-Za-z0-9\-\.\+]+@([A-Za-z0-9\-]+\.)+[A-Za-z0-9\-]{2,}$'),
    USER_PASSWORD   VARCHAR(256) NOT NULL,
    USER_GENDER     CHAR(1) NOT NULL CHECK (USER_GENDER IN ('M', 'F')),
    USER_BIRTHDATE  DATE NOT NULL,
    USER_HEIGHT     DECIMAL(4,1) NOT NULL CHECK (USER_HEIGHT > 0.0),
    USER_LEVEL      VARCHAR(16) NOT NULL DEFAULT 'BEGINNER' CHECK (USER_LEVEL IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    PLAN_ID         BIGINT UNSIGNED,
    PRIMARY KEY (USER_ID)
);

CREATE TABLE PLAN (
    PLAN_ID            SERIAL,
    PLAN_CREATED       DATE NOT NULL DEFAULT CURRENT_DATE,
    PLAN_STARTED       DATE,
    USER_ID            BIGINT UNSIGNED NOT NULL,
    REGIMEN_ID         BIGINT UNSIGNED,
    SLEEP_ID           BIGINT UNSIGNED,
    DIET_ID            BIGINT UNSIGNED,
    PRIMARY KEY (PLAN_ID),
    CONSTRAINT PLAN_CREATED_BEFORE_STARTED CHECK (PLAN_STARTED >= PLAN_CREATED)
);

CREATE TABLE MEASUREMENT (
    MEASUREMENT_DATE   DATE NOT NULL UNIQUE DEFAULT CURRENT_DATE,
    MEASUREMENT_WEIGHT DECIMAL(4,1) NOT NULL CHECK (MEASUREMENT_WEIGHT > 0.0),
    USER_ID            BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (MEASUREMENT_DATE)
);

CREATE TABLE REGIMEN (
    REGIMEN_ID            SERIAL,
    REGIMEN_NAME          VARCHAR(64) NOT NULL UNIQUE,
    REGIMEN_DESCRIPTION   VARCHAR(512) NOT NULL,
    REGIMEN_SPAN_QUANTITY TINYINT(2) UNSIGNED NOT NULL,
    REGIMEN_SPAN_UNIT     CHAR(1) NOT NULL CHECK (REGIMEN_SPAN_UNIT IN ('D', 'W', 'M')),
    REGIMEN_LEVEL         VARCHAR(16) NOT NULL DEFAULT 'BEGINNER' CHECK (REGIMEN_LEVEL IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    PRIMARY KEY (REGIMEN_ID)
);

CREATE TABLE WORKOUT (
    WORKOUT_ID          SERIAL,
    WORKOUT_DAY_OF_WEEK CHAR(1) NOT NULL CHECK (WORKOUT_DAY_OF_WEEK IN ('M', 'T', 'W', 'R', 'F', 'S', 'U')),
    REGIMEN_ID          BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (WORKOUT_ID)
);

CREATE TABLE ROUTINE (
    WORKOUT_ID       BIGINT UNSIGNED NOT NULL,
    EXERCISE_ID      BIGINT UNSIGNED NOT NULL,
    ROUTINE_QUANTITY SMALLINT(4) UNSIGNED NOT NULL,
    UNIQUE (WORKOUT_ID, EXERCISE_ID),
    PRIMARY KEY (WORKOUT_ID, EXERCISE_ID)
);

CREATE TABLE EXERCISE (
    EXERCISE_ID          SERIAL,
    EXERCISE_NAME        VARCHAR(64) NOT NULL UNIQUE,
    EXERCISE_DESCRIPTION VARCHAR(512) NOT NULL,
    PRIMARY KEY (EXERCISE_ID)
);

CREATE TABLE PERFORMANCE (
    PERFORMANCE_ID       SERIAL,
    PERFORMANCE_DATE     DATE NOT NULL DEFAULT CURRENT_DATE,
    PERFORMANCE_TIME     TIME NOT NULL DEFAULT CURRENT_TIME CHECK (PERFORMANCE_TIME BETWEEN '00:00:00' AND '23:59:59'),
    PERFORMANCE_QUANTITY SMALLINT(4) NOT NULL,
    WORKOUT_ID           BIGINT UNSIGNED,
    EXERCISE_ID          BIGINT UNSIGNED NOT NULL,
    USER_ID              BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (PERFORMANCE_ID)
);

CREATE TABLE SLEEP (
    SLEEP_ID       SERIAL,
    SLEEP_HOURS    DECIMAL(4,2) NOT NULL CHECK (SLEEP_HOURS >= 0.0),
    SLEEP_END_TIME TIME CHECK (SLEEP_END_TIME BETWEEN '00:00:00' AND '23:59:59'),
    PRIMARY KEY (SLEEP_ID)
);

CREATE TABLE REST (
    REST_ID         SERIAL,
    REST_START_DATE DATE NOT NULL,
    REST_START_TIME TIME NOT NULL CHECK (REST_START_TIME BETWEEN '00:00:00' AND '23:59:59'),
    REST_END_DATE   DATE NOT NULL,
    REST_END_TIME   TIME NOT NULL CHECK (REST_END_TIME BETWEEN '00:00:00' AND '23:59:59'),
    SLEEP_ID        BIGINT UNSIGNED,
    USER_ID         BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (REST_ID),
    CONSTRAINT RESTED_WITHIN_ONE_DAY CHECK (DATEDIFF(REST_END_DATE, REST_START_DATE) BETWEEN 0 AND 1),
    CONSTRAINT RESTED_WITHIN_TWELVE_HOURS CHECK (TIMEDIFF(TIMESTAMP(REST_END_DATE, REST_END_TIME), TIMESTAMP(REST_START_DATE, REST_START_TIME)) BETWEEN '00:00:00' AND '12:00:00')
);

CREATE TABLE DIET (
    DIET_ID            SERIAL,
    DIET_NAME          VARCHAR(64) NOT NULL UNIQUE,
    DIET_DESCRIPTION   VARCHAR(512) NOT NULL,
    DIET_SPAN_QUANTITY TINYINT(2) UNSIGNED NOT NULL,
    DIET_SPAN_UNIT     CHAR(1) NOT NULL CHECK (DIET_SPAN_UNIT IN ('W', 'M', 'Y')),
    PRIMARY KEY (DIET_ID)
);

CREATE TABLE MEAL (
    DIET_ID      BIGINT UNSIGNED NOT NULL,
    MEAL_NAME    VARCHAR(16) NOT NULL CHECK (MEAL_NAME IN ('BREAKFAST', 'BRUNCH', 'LUNCH', 'DINNER', 'SNACK')),
    NUTRITION_ID BIGINT UNSIGNED NOT NULL UNIQUE,
    UNIQUE (DIET_ID, MEAL_NAME),
    PRIMARY KEY (DIET_ID, MEAL_NAME)
);

CREATE TABLE FOODSTUFF (
    FOODSTUFF_ID          SERIAL,
    FOODSTUFF_NAME        VARCHAR(64) NOT NULL UNIQUE,
    FOODSTUFF_DESCRIPTION VARCHAR(512) NOT NULL,
    FOODSTUFF_SERVINGS    SMALLINT(4) UNSIGNED NOT NULL,
    NUTRITION_ID          BIGINT UNSIGNED NOT NULL UNIQUE,
    PRIMARY KEY (FOODSTUFF_ID)
);

CREATE TABLE NUTRITION (
    NUTRITION_ID                  SERIAL,
    NUTRITION_SERVINGS_QUANTITY   DECIMAL(6,2) NOT NULL CHECK (NUTRITION_SERVINGS_QUANTITY > 0.0),
    NUTRITION_SERVINGS_UNIT       VARCHAR(32) NOT NULL,
    NUTRITION_CALORIES            SMALLINT(4) UNSIGNED NOT NULL,
    NUTRITION_SATURATED_FAT       DECIMAL(4,1) NOT NULL CHECK (NUTRITION_SATURATED_FAT >= 0.0),
    NUTRITION_MONOUNSATURATED_FAT DECIMAL(4,1) NOT NULL CHECK (NUTRITION_MONOUNSATURATED_FAT >= 0.0),
    NUTRITION_POLYUNSATURATED_FAT DECIMAL(4,1) NOT NULL CHECK (NUTRITION_POLYUNSATURATED_FAT >= 0.0),
    NUTRITION_TRANS_FAT           DECIMAL(4,1) NOT NULL CHECK (NUTRITION_TRANS_FAT >= 0.0),
    NUTRITION_CHOLESTEROL         DECIMAL(6,1) NOT NULL CHECK (NUTRITION_CHOLESTEROL >= 0.0),
    NUTRITION_SODIUM              DECIMAL(6,1) NOT NULL CHECK (NUTRITION_SODIUM >= 0.0),
    NUTRITION_FIBER               DECIMAL(4,1) NOT NULL CHECK (NUTRITION_FIBER >= 0.0),
    NUTRITION_SUGAR               DECIMAL(4,1) NOT NULL CHECK (NUTRITION_SUGAR >= 0.0),
    NUTRITION_OTHER_CARBOHYDRATE  DECIMAL(4,1) NOT NULL CHECK (NUTRITION_OTHER_CARBOHYDRATE >= 0.0),
    NUTRITION_PROTEIN             DECIMAL(4,1) NOT NULL CHECK (NUTRITION_PROTEIN >= 0.0),
    NUTRITION_VITAMIN_A           DECIMAL(6,1) NOT NULL CHECK (NUTRITION_VITAMIN_A >= 0.0),
    NUTRITION_VITAMIN_C           DECIMAL(6,1) NOT NULL CHECK (NUTRITION_VITAMIN_C >= 0.0),
    NUTRITION_CALCIUM             DECIMAL(6,1) NOT NULL CHECK (NUTRITION_CALCIUM >= 0.0),
    NUTRITION_IRON                DECIMAL(6,1) NOT NULL CHECK (NUTRITION_IRON >= 0.0),
    PRIMARY KEY (NUTRITION_ID)
);

CREATE TABLE FOOD (
    FOOD_ID      SERIAL,
    FOOD_DATE    DATE NOT NULL DEFAULT CURRENT_DATE,
    FOOD_TIME    TIME NOT NULL DEFAULT CURRENT_TIME CHECK (FOOD_TIME BETWEEN '00:00:00' AND '23:59:59'),
    FOOD_COUNT   SMALLINT(2) UNSIGNED NOT NULL, 
    DIET_ID      BIGINT UNSIGNED,
    MEAL_NAME    VARCHAR(16),
    FOODSTUFF_ID BIGINT UNSIGNED NOT NULL,
    USER_ID      BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (FOOD_ID)
);


INSERT INTO USER (USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL, USER_PASSWORD, USER_GENDER, USER_BIRTHDATE, USER_HEIGHT, USER_LEVEL, PLAN_ID)
VALUES
    ('John', 'Doe', 'j.doe1@apple.com', 'a4991124a5d34aabe94ae5a03cbc5052fdfa651d', 'M', '1990-05-15', 175.0, 'BEGINNER', 1),
    ('Jane', 'Smith', 'jane-smith@myspace.com', '663d58cf8ed34cfd052fd2a56c747c96a7a7951b', 'F', '1995-08-20', 163.5, 'INTERMEDIATE', 2),
    ('David', 'Johnson', 'david.johnson123@economist.com', '58616d124df5ccf55f89c85be3cea1a562273ae2', 'M', '1988-11-10', 180.0, 'ADVANCED', 3),
    ('Emily', 'Brown', 'emilybrown2022@ebay.co.uk', '7b9d8d72b4c239f363b052e2698b95f5d724d2ff', 'F', '1993-02-25', 159.0, 'INTERMEDIATE', 4),
    ('Michael', 'Wilson', 'michaelw@free.fr', '43280aa8ca42bfe1ef367621a8c2bd36140abe50', 'M', '1985-07-01', 185.5, 'BEGINNER', NULL);

INSERT INTO PLAN (PLAN_CREATED, PLAN_STARTED, USER_ID, REGIMEN_ID, SLEEP_ID, DIET_ID)
VALUES
    ('2023-04-24', '2023-05-01', 1, 1, 2, 3),
    ('2023-05-01', '2023-05-02', 2, NULL, 4, 5),
    ('2023-05-03', '2023-05-03', 3, 11, NULL, 1),
    ('2023-04-30', '2023-05-01', 4, 9, 6, 3),
    ('2023-05-05', NULL, 5, 15, 4, 1);

INSERT INTO MEASUREMENT (MEASUREMENT_DATE, MEASUREMENT_WEIGHT, USER_ID)
VALUES
    ('2023-05-01', 70.2, 1),
    ('2023-05-08', 67.2, 1),
    ('2023-05-02', 62.5, 2),
    ('2023-05-09', 59.5, 2),
    ('2023-05-03', 85.0, 3),
    ('2023-05-10', 82.0, 3),
    ('2023-05-04', 57.0, 4),
    ('2023-05-11', 54.0, 4);

INSERT INTO REGIMEN (REGIMEN_NAME, REGIMEN_DESCRIPTION, REGIMEN_SPAN_QUANTITY, REGIMEN_SPAN_UNIT, REGIMEN_LEVEL)
VALUES
    ('Full Body Beginner', 'A beginner-level exercise program targeting the entire body. Ideal for individuals new to fitness.', 7, 'D', 'BEGINNER'),
    ('Cardiovascular Conditioning', 'A beginner-level exercise program focused on improving cardiovascular health and endurance.', 14, 'D', 'BEGINNER'),
    ('Strength Training Basics', 'A beginner-level exercise program that introduces foundational strength training exercises.', 3, 'W', 'BEGINNER'),
    ('Low-Impact Aerobics', 'A beginner-level exercise program consisting of low-impact aerobic exercises for joint-friendly workouts.', 5, 'W', 'BEGINNER'),
    ('Flexibility and Mobility', 'A beginner-level exercise program emphasizing stretching and mobility exercises for improved flexibility.', 1, 'M', 'BEGINNER'),
    ('Upper/Lower Split', 'An intermediate-level exercise program dividing workouts into upper body and lower body training sessions.', 5, 'D', 'INTERMEDIATE'),
    ('HIIT Circuit Training', 'An intermediate-level exercise program combining high-intensity interval training (HIIT) and circuit training.', 10, 'D', 'INTERMEDIATE'),
    ('Functional Strength Training', 'An intermediate-level exercise program focusing on functional movements and compound exercises.', 2, 'W', 'INTERMEDIATE'),
    ('Core Strengthening', 'An intermediate-level exercise program targeting the core muscles for improved stability and strength.', 4, 'W', 'INTERMEDIATE'),
    ('Pilates and Yoga Fusion', 'An intermediate-level exercise program combining elements of Pilates and yoga for body awareness and balance.', 2, 'M', 'INTERMEDIATE'),
    ('Powerlifting Program', 'An advanced-level exercise program designed to enhance strength and performance in the squat, bench press, and deadlift.', 4, 'D', 'ADVANCED'),
    ('High-Volume Bodybuilding', 'An advanced-level exercise program focused on high-volume training for muscle hypertrophy and development.', 7, 'D', 'ADVANCED'),
    ('Sports-Specific Training', 'An advanced-level exercise program tailored to enhance performance in a specific sport or athletic activity.', 1, 'W', 'ADVANCED'),
    ('Advanced Plyometric Training', 'An advanced-level exercise program incorporating explosive plyometric exercises for power and agility.', 3, 'W', 'ADVANCED'),
    ('Olympic Weightlifting Program', 'An advanced-level exercise program emphasizing the snatch and clean and jerk for Olympic weightlifting.', 1, 'M', 'ADVANCED');

INSERT INTO WORKOUT (WORKOUT_DAY_OF_WEEK, REGIMEN_ID)
VALUES
    ('M', 1),
    ('W', 1),
    ('T', 2),
    ('R', 2),
    ('M', 3),
    ('W', 3),
    ('T', 4),
    ('R', 4),
    ('M', 5),
    ('W', 5),
    ('T', 6),
    ('R', 6),
    ('S', 6),
    ('M', 7),
    ('W', 7),
    ('F', 7),
    ('T', 8),
    ('R', 8),
    ('S', 8),
    ('M', 9),
    ('W', 9),
    ('F', 9),
    ('T', 10),
    ('R', 10),
    ('S', 10),
    ('M', 11),
    ('W', 11),
    ('F', 11),
    ('S', 11),
    ('T', 12),
    ('R', 12),
    ('S', 12),
    ('U', 12),
    ('M', 13),
    ('W', 13),
    ('F', 13),
    ('S', 13),
    ('T', 14),
    ('R', 14),
    ('S', 14),
    ('U', 14),
    ('M', 15),
    ('W', 15),
    ('F', 15),
    ('S', 15);

INSERT INTO EXERCISE (EXERCISE_NAME, EXERCISE_DESCRIPTION)
VALUES
    ('Push-ups', 'A classic bodyweight exercise that primarily targets the chest, shoulders, and triceps.'),
    ('Squats', 'A compound lower-body exercise that targets the quadriceps, hamstrings, and glutes.'),
    ('Plank', 'A core-strengthening exercise that engages the abdominal muscles, lower back, and shoulders.'),
    ('Lunges', 'An exercise that targets the quadriceps, hamstrings, and glutes, while also improving balance.'),
    ('Bicep Curls', 'An isolation exercise that primarily targets the biceps, promoting upper-arm strength and definition.'),
    ('Mountain Climbers', 'A dynamic exercise that engages the core, shoulders, and lower body while improving cardiovascular endurance.'),
    ('Deadlifts', 'A compound exercise that targets multiple muscle groups, including the hamstrings, glutes, and back.'),
    ('Russian Twists', 'An exercise that targets the obliques and core muscles, promoting rotational strength.'),
    ('Burpees', 'A full-body exercise that combines a squat, push-up, and jump, providing a challenging cardiovascular workout.'),
    ('Dumbbell Shoulder Press', 'An exercise that targets the shoulders and triceps, promoting upper-body strength and stability.'),
    ('Crunches', 'An abdominal exercise that primarily targets the rectus abdominis, commonly known as the six-pack muscles.'),
    ('Leg Press', 'A compound exercise performed on a weight machine that targets the quadriceps, hamstrings, and glutes.'),
    ('Pull-ups', 'A challenging upper-body exercise that primarily targets the back and biceps.'),
    ('Calf Raises', 'An exercise that targets the calf muscles, helping to improve lower-leg strength and stability.'),
    ('Tricep Dips', 'An exercise that targets the triceps and chest muscles, promoting upper-body strength.'),
    ('Side Plank', 'A variation of the plank exercise that engages the side abdominal muscles, promoting core stability.'),
    ('Bench Press', 'A compound exercise that primarily targets the chest, shoulders, and triceps.'),
    ('Hip Thrusts', 'An exercise that targets the glutes and hamstrings, helping to improve hip strength and stability.'),
    ('Leg Extensions', 'An isolation exercise that targets the quadriceps, promoting leg strength and definition.'),
    ('Seated Rows', 'An exercise that targets the back muscles, including the latissimus dorsi and rhomboids.');

INSERT INTO ROUTINE (WORKOUT_ID, EXERCISE_ID, ROUTINE_QUANTITY)
VALUES
    (1, 1, 10),
    (1, 2, 15),
    (2, 3, 20),
    (2, 4, 12),
    (3, 5, 8),
    (3, 6, 30),
    (4, 7, 10),
    (4, 8, 20),
    (5, 9, 10),
    (5, 10, 12),
    (6, 11, 12),
    (6, 12, 10),
    (7, 13, 8),
    (7, 14, 15),
    (8, 15, 12),
    (8, 16, 20),
    (9, 17, 10),
    (9, 18, 15),
    (10, 19, 12),
    (10, 20, 10),
    (11, 1, 15),
    (11, 2, 20),
    (11, 3, 30),
    (11, 4, 15),
    (12, 5, 12),
    (12, 6, 40),
    (12, 7, 12),
    (12, 8, 25),
    (13, 9, 15),
    (13, 10, 15),
    (13, 11, 15),
    (13, 12, 12),
    (14, 13, 10),
    (14, 14, 20),
    (14, 15, 15),
    (14, 16, 30),
    (15, 17, 12),
    (15, 18, 20),
    (15, 19, 15),
    (15, 20, 12);

INSERT INTO SLEEP (SLEEP_HOURS, SLEEP_END_TIME)
VALUES
    (6.5, '08:00:00'),
    (7.0, '07:30:00'),
    (8.0, '07:00:00'),
    (8.5, '06:30:00'),
    (9.0, '06:00:00'),
    (6.5, NULL),
    (7.0, NULL),
    (8.0, NULL),
    (8.5, NULL),
    (9.0, NULL);

INSERT INTO DIET (DIET_NAME, DIET_DESCRIPTION, DIET_SPAN_QUANTITY, DIET_SPAN_UNIT)
VALUES
    ('Low Carb', 'A diet plan that restricts carbohydrate intake.', 2, 'W'),
    ('Mediterranean', 'A diet plan based on traditional Mediterranean cuisine.', 1, 'M'),
    ('Paleo', 'A diet plan that focuses on consuming unprocessed foods.', 3, 'W'),
    ('Vegetarian', 'A diet plan that excludes meat and seafood.', 1, 'Y'),
    ('Ketogenic', 'A diet plan that involves high fat and low carbohydrate intake.', 2, 'M');

INSERT INTO NUTRITION (NUTRITION_SERVINGS_QUANTITY, NUTRITION_SERVINGS_UNIT, NUTRITION_CALORIES, NUTRITION_SATURATED_FAT, NUTRITION_MONOUNSATURATED_FAT, NUTRITION_POLYUNSATURATED_FAT, NUTRITION_TRANS_FAT, NUTRITION_CHOLESTEROL, NUTRITION_SODIUM, NUTRITION_FIBER, NUTRITION_SUGAR, NUTRITION_OTHER_CARBOHYDRATE, NUTRITION_PROTEIN, NUTRITION_VITAMIN_A, NUTRITION_VITAMIN_C, NUTRITION_CALCIUM, NUTRITION_IRON)
VALUES
    (1, 'CUP', 7, 0.0, 0.0, 0.0, 0.0, 0.0, 24.0, 0.7, 0.1, 0.4, 0.9, 2813, 8.4, 30.7, 1.0),
    (1, 'CUP', 33, 0.0, 0.1, 0.1, 0.0, 0.0, 29.0, 1.3, 0.0, 6.7, 2.2, 8851, 80.4, 136.0, 2.5),
    (1, 'CUP', 55, 0.0, 0.0, 0.1, 0.0, 0.0, 30.0, 2.3, 1.5, 4.6, 2.6, 567, 135.2, 41.2, 2.3),
    (1, 'MEDIUM', 112, 0.1, 0.0, 0.0, 0.0, 0.0, 41.4, 4.0, 7.0, 26.2, 2.0, 21909, 22.3, 39.2, 0.8),
    (1, 'CUP', 222, 0.3, 0.3, 1.2, 0.0, 0.0, 13.3, 2.0, 0.9, 39.4, 8.1, 9, 0.4, 31.5, 2.8),
    (1, 'CUP', 147, 0.4, 0.4, 0.2, 0.0, 0.0, 2.8, 4.0, 1.0, 25.3, 6.1, 9, 0.0, 54.1, 4.7),
    (1, 'CUP', 216, 0.4, 0.6, 1.5, 0.0, 0.0, 10.4, 1.8, 0.4, 45.8, 4.5, 18, 0.0, 19.5, 1.8),
    (1, 'FILLET', 412, 2.2, 4.6, 3.2, 0.0, 109.2, 54.4, 0.0, 0.0, 0.0, 69.6, 787, 0.0, 34.7, 2.0),
    (1, 'FILLET', 118, 0.3, 0.3, 0.5, 0.0, 31.5, 29.5, 0.0, 0.0, 0.0, 25.4, 8, 0.0, 4.5, 1.2),
    (1, 'BREAST', 165, 0.9, 0.9, 0.2, 0.0, 82.4, 64.5, 0.0, 0.0, 0.0, 31.0, 7, 0.0, 6.6, 0.4),
    (1, 'BREAST', 189, 0.5, 0.6, 0.1, 0.0, 72.0, 83.0, 0.0, 0.0, 0.0, 34.0, 0, 0.0, 6.6, 0.6),
    (1, 'LARGE', 78, 1.6, 1.9, 0.4, 0.0, 186.5, 62.5, 0.0, 0.6, 0.6, 6.3, 315, 0.0, 24.6, 0.8),
    (1, 'CUP', 130, 0.6, 0.3, 0.0, 0.0, 10.0, 70.0, 0.0, 9.0, 6.0, 23.0, 3, 0.0, 24.0, 0.1),
    (1, 'CUP', 206, 5.5, 2.9, 0.2, 0.0, 68.0, 918.0, 0.0, 6.0, 10.4, 27.0, 16, 0.0, 125.0, 0.4),
    (1, 'OUNCE', 164, 1.2, 9.4, 2.4, 0.0, 0.0, 1.0, 3.5, 1.0, 6.1, 6.0, 1, 0.0, 76.4, 1.0),
    (1, 'OUNCE', 185, 1.7, 13.4, 2.5, 0.0, 0.0, 2.0, 1.9, 0.7, 7.8, 4.3, 1, 0.0, 28.7, 0.8),
    (1, 'OUNCE', 138, 0.9, 2.0, 3.3, 0.0, 0.0, 5.5, 9.8, 0.0, 11.2, 4.7, 0, 0.0, 17.8, 0.6),
    (1, 'TABLESPOON', 37, 0.3, 0.6, 1.4, 0.0, 0.0, 1.5, 2.8, 0.1, 2.0, 1.3, 1, 0.0, 26.0, 0.6),
    (1, 'MEDIUM', 234, 3.7, 11.3, 1.8, 0.0, 0.0, 10.0, 9.8, 0.0, 12.5, 2.7, 293, 20.1, 22.0, 1.0),
    (1, 'TABLESPOON', 119, 2.0, 10.3, 1.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0),
    (1, 'TABLESPOON', 121, 11.2, 0.8, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0),
    (1, 'CUP', 84, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, 3.6, 14.7, 21.4, 1.1, 80, 14.4, 9.2, 0.4),
    (1, 'CUP', 49, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, 2.0, 7.4, 11.7, 1.0, 12, 89.4, 23.2, 0.6),
    (1, 'CUP', 64, 0.0, 0.0, 0.3, 0.0, 0.0, 1.0, 8.0, 4.4, 14.7, 1.5, 32, 32.2, 30.7, 0.8),
    (1, 'CUP', 62, 0.0, 0.0, 0.3, 0.0, 0.0, 1.0, 7.6, 7.0, 13.8, 2.0, 25, 30.2, 29.7, 0.9),
    (1, 'MEDIUM', 62, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, 3.1, 12.2, 15.4, 1.2, 344, 66.7, 61.6, 0.9),
    (1, 'MEDIUM', 95, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 4.4, 18.9, 25.1, 0.5, 73, 8.4, 7.9, 0.2),
    (1, 'MEDIUM', 105, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, 3.1, 14.4, 27.0, 1.3, 75, 10.3, 6.8, 0.3),
    (1, 'CUP', 104, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.8, 22.4, 26.8, 0.6, 12, 3.7, 15.8, 0.3),
    (1, 'MEDIUM', 22, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, 1.5, 3.9, 4.8, 1.1, 766, 17.0, 9.0, 0.5),
    (1, 'MEDIUM', 25, 0.0, 0.0, 0.1, 0.0, 0.0, 42.0, 1.7, 6.0, 5.8, 0.5, 16706, 3.6, 20.1, 0.2),
    (1, 'MEDIUM', 37, 0.0, 0.0, 0.3, 0.0, 0.0, 1.0, 1.3, 3.9, 6.3, 1.5, 436, 117.7, 18.9, 0.6),
    (1, 'CUP', 21, 0.0, 0.0, 0.1, 0.0, 0.0, 2.0, 2.2, 1.0, 3.2, 3.0, 5, 0.0, 2.3, 0.6),
    (1, 'CLOVE', 4, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.2, 0.0, 1.0, 0.2, 0, 0.0, 5.4, 0.1),
    (1, 'TABLESPOON', 18, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 4.2, 4.8, 0.2, 0, 0.0, 0.5, 0.6),
    (1, 'TEASPOON', 9, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.7, 2.0, 2.0, 0.2, 0, 0.0, 0.2, 0.4),
    (1, 'CUP', 230, 0.1, 0.0, 1.0, 0.0, 0.0, 2.0, 15.6, 9.0, 39.9, 17.9, 16, 0.0, 37.9, 6.6),
    (1, 'CUP', 269, 0.5, 0.0, 2.5, 0.0, 0.0, 0.0, 12.5, 45.0, 49.0, 14.5, 5, 0.0, 80.4, 12.5),
    (1, 'CUP', 225, 0.1, 0.0, 1.1, 0.0, 0.0, 0.0, 11.3, 8.4, 40.4, 15.4, 1, 0.0, 39.3, 8.2),
    (1, 'CUP', 227, 0.1, 0.0, 0.6, 0.0, 0.0, 0.0, 14.0, 7.3, 41.4, 15.2, 0, 0.0, 46.4, 8.8),
    (1, 'CUP', 31, 0.1, 0.0, 0.1, 0.0, 0.0, 0.0, 3.6, 1.8, 7.8, 1.8, 19, 15.2, 40.1, 0.7),
    (1, 'CUP', 62, 0.1, 0.0, 0.1, 0.0, 0.0, 0.0, 8.8, 9.0, 25.0, 4.0, 24, 12.2, 36.0, 2.5),
    (1, 'CUP', 25, 0.0, 0.0, 0.1, 0.0, 0.0, 30.0, 2.0, 5.0, 5.0, 1.3, 22, 0.0, 16.0, 0.4),
    (1, 'CUP', 27, 0.0, 0.0, 0.2, 0.0, 0.0, 2.0, 2.8, 2.9, 5.2, 2.9, 69, 6.0, 41.6, 2.9),
    (1, 'CUP', 7, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.7, 0.5, 1.3, 0.9, 11, 2815.4, 29.7, 0.6),
    (1, 'CUP', 154, 4.9, 7.4, 2.3, 0.0, 0.0, 20.0, 3.6, 4.4, 7.4, 4.4, 1, 7.8, 18.5, 0.8),
    (1, 'CUP', 222, 4.4, 3.1, 1.7, 0.0, 0.0, 0.0, 42.2, 8.8, 39.4, 8.1, 1, 3.2, 31.5, 6.3),
    (1, 'CUP', 140, 10.5, 6.2, 0.4, 0.0, 0.0, 29.0, 3.6, 3.9, 6.2, 5.6, 1, 15.4, 15.0, 0.4),
    (1, 'CUP', 74, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, 18.4, 3.6, 19.3, 0.9, 1, 177, 34.4, 0.5),
    (1, 'OUNCE', 173, 1.6, 3.8, 6.2, 0.0, 0.0, 0.0, 5.9, 2.1, 7.7, 6.0, 1, 0.0, 15.2, 1.2),
    (1, 'MEAL', 350, 4.5, 2.5, 2.0, 0.0, 120, 400, 6.0, 3.0, 10.0, 30.0, 200, 15, 20, 2),
    (1, 'MEAL', 400, 6.0, 3.5, 2.5, 0.0, 150, 450, 8.0, 4.0, 12.0, 35.0, 250, 20, 25, 3),
    (1, 'MEAL', 450, 7.0, 4.0, 3.0, 0.0, 180, 500, 10.0, 5.0, 14.0, 40.0, 300, 25, 30, 4),
    (1, 'MEAL', 500, 8.0, 4.5, 3.5, 0.0, 200, 550, 12.0, 6.0, 16.0, 45.0, 350, 30, 35, 5),
    (1, 'MEAL', 400, 5.0, 3.0, 2.0, 0.0, 100, 300, 8.0, 4.0, 10.0, 20.0, 300, 25, 30, 4),
    (1, 'MEAL', 450, 6.0, 3.5, 2.5, 0.0, 120, 350, 10.0, 5.0, 12.0, 25.0, 350, 30, 35, 5),
    (1, 'MEAL', 500, 7.0, 4.0, 3.0, 0.0, 150, 400, 12.0, 6.0, 14.0, 30.0, 400, 35, 40, 6),
    (1, 'MEAL', 250, 3.0, 2.0, 1.0, 0.0, 80, 200, 4.0, 2.0, 8.0, 15.0, 200, 20, 20, 3),
    (1, 'MEAL', 300, 3.5, 2.0, 1.5, 0.0, 90, 250, 6.0, 3.0, 8.0, 20.0, 250, 15, 20, 2),
    (1, 'MEAL', 350, 4.5, 2.5, 2.0, 0.0, 120, 300, 8.0, 4.0, 10.0, 25.0, 300, 20, 25, 3),
    (1, 'MEAL', 400, 6.0, 3.0, 2.5, 0.0, 150, 350, 10.0, 5.0, 12.0, 30.0, 350, 25, 30, 4),
    (1, 'MEAL', 450, 7.0, 3.5, 3.0, 0.0, 180, 400, 12.0, 6.0, 14.0, 35.0, 400, 30, 35, 5),
    (1, 'MEAL', 350, 4.5, 2.5, 2.0, 0.0, 120, 400, 6.0, 3.0, 10.0, 30.0, 200, 15, 20, 2),
    (1, 'MEAL', 400, 6.0, 3.5, 2.5, 0.0, 150, 450, 8.0, 4.0, 12.0, 35.0, 250, 20, 25, 3),
    (1, 'MEAL', 450, 7.0, 4.0, 3.0, 0.0, 180, 500, 10.0, 5.0, 14.0, 40.0, 300, 25, 30, 4),
    (1, 'MEAL', 400, 5.0, 3.0, 2.0, 0.0, 100, 300, 8.0, 4.0, 10.0, 20.0, 300, 25, 30, 4),
    (1, 'MEAL', 450, 6.0, 3.5, 2.5, 0.0, 120, 350, 10.0, 5.0, 12.0, 25.0, 350, 30, 35, 5),
    (1, 'MEAL', 500, 7.0, 4.0, 3.0, 0.0, 150, 400, 12.0, 6.0, 14.0, 30.0, 400, 35, 40, 6),
    (1, 'MEAL', 550, 8.0, 4.5, 3.5, 0.0, 180, 450, 14.0, 7.0, 16.0, 35.0, 450, 40, 45, 7),
    (1, 'MEAL', 600, 9.0, 5.0, 4.0, 0.0, 200, 500, 16.0, 8.0, 18.0, 40.0, 500, 45, 50, 8);

INSERT INTO FOODSTUFF (FOODSTUFF_NAME, FOODSTUFF_DESCRIPTION, FOODSTUFF_SERVINGS, NUTRITION_ID)
VALUES
    ('Spinach', 'Leafy green vegetable rich in vitamins and minerals', 1, 1),
    ('Kale', 'Nutrient-dense leafy green vegetable', 1, 2),
    ('Broccoli', 'Cruciferous vegetable with high fiber content', 1, 3),
    ('Sweet Potato', 'Nutritious root vegetable with natural sweetness', 1, 4),
    ('Quinoa', 'Protein-rich grain alternative', 1, 5),
    ('Oats', 'Whole grain cereal with high fiber content', 1, 6),
    ('Brown Rice', 'Nutritious whole grain with bran intact', 1, 7),
    ('Salmon', 'Fatty fish rich in omega-3 fatty acids', 1, 8),
    ('Tuna', 'Lean fish high in protein', 1, 9),
    ('Chicken Breast', 'Lean source of protein', 1, 10),
    ('Turkey Breast', 'Lean meat with low fat content', 1, 11),
    ('Eggs', 'Protein-packed breakfast staple', 2, 12),
    ('Greek Yogurt', 'Creamy and protein-rich dairy product', 1, 13),
    ('Cottage Cheese', 'Low-fat cheese with high protein content', 1, 14),
    ('Almonds', 'Nutrient-dense tree nuts', 1, 15),
    ('Walnuts', 'Omega-3 fatty acid-rich nuts', 1, 16),
    ('Chia Seeds', 'Tiny seeds packed with fiber and omega-3s', 1, 17),
    ('Flaxseeds', 'Rich in omega-3 fatty acids and fiber', 1, 18),
    ('Avocado', 'Healthy fruit with monounsaturated fats', 1, 19),
    ('Olive Oil', 'Heart-healthy cooking oil', 1, 20),
    ('Coconut Oil', 'Versatile oil with potential health benefits', 1, 21),
    ('Blueberries', 'Antioxidant-rich berries', 1, 22),
    ('Strawberries', 'Vitamin C-rich berries', 1, 23),
    ('Raspberries', 'Fiber-packed berries with natural sweetness', 1, 24),
    ('Blackberries', 'Antioxidant-rich dark berries', 1, 25),
    ('Oranges', 'Citrus fruit abundant in vitamin C', 1, 26),
    ('Apples', 'Fiber-rich fruit with various nutrients', 1, 27),
    ('Bananas', 'Naturally sweet fruit with potassium', 1, 28),
    ('Grapes', 'Juicy fruit rich in antioxidants', 1, 29),
    ('Tomatoes', 'Vitamin C and lycopene-rich fruit', 1, 30),
    ('Carrots', 'Crunchy root vegetable packed with beta-carotene', 1, 31),
    ('Bell Peppers', 'Colorful vegetables with high vitamin C content', 1, 32),
    ('Mushrooms', 'Nutrient-dense fungi with unique flavor', 1, 33),
    ('Garlic', 'Aromatic bulb with potential health benefits', 1, 34),
    ('Ginger', 'Spice with anti-inflammatory properties', 1, 35),
    ('Turmeric', 'Bright yellow spice with potential health benefits', 1, 36),
    ('Lentils', 'Protein-packed legumes', 1, 37),
    ('Chickpeas', 'Versatile legume rich in fiber and protein', 1, 38),
    ('Kidney Beans', 'Nutritious beans with high fiber content', 1, 39),
    ('Black Beans', 'Protein and fiber-rich legumes', 1, 40),
    ('Green Beans', 'Low-calorie vegetable with fiber', 1, 41),
    ('Peas', 'Sweet and starchy vegetable', 1, 42),
    ('Cauliflower', 'Versatile cruciferous vegetable', 1, 43),
    ('Asparagus', 'Delicate vegetable with various nutrients', 1, 44),
    ('Spinach Salad', 'Fresh and nutritious green salad', 1, 45),
    ('Greek Salad', 'Traditional Mediterranean salad', 1, 46),
    ('Quinoa Salad', 'Healthy grain salad with vegetables', 1, 47),
    ('Caprese Salad', 'Classic Italian salad with tomatoes and mozzarella', 1, 48),
    ('Fruit Salad', 'Assortment of fresh and colorful fruits', 1, 49),
    ('Mixed Nuts', 'Assorted nuts with various health benefits', 1, 50);

INSERT INTO MEAL (DIET_ID, MEAL_NAME, NUTRITION_ID)
VALUES
    (1, 'BREAKFAST', 51),
    (1, 'BRUNCH', 52),
    (1, 'LUNCH', 53),
    (1, 'DINNER', 54),
    (2, 'BREAKFAST', 55),
    (2, 'LUNCH', 56),
    (2, 'DINNER', 57),
    (2, 'SNACK', 58),
    (3, 'BREAKFAST', 59),
    (3, 'BRUNCH', 60),
    (3, 'LUNCH', 61),
    (3, 'DINNER', 62),
    (3, 'SNACK', 63),
    (4, 'BREAKFAST', 64),
    (4, 'LUNCH', 65),
    (4, 'DINNER', 66),
    (5, 'BREAKFAST', 67),
    (5, 'BRUNCH', 68),
    (5, 'LUNCH', 69),
    (5, 'DINNER', 70);

INSERT INTO PERFORMANCE (PERFORMANCE_DATE, PERFORMANCE_TIME, PERFORMANCE_QUANTITY, WORKOUT_ID, EXERCISE_ID, USER_ID)
VALUES
    ('2023-05-01', '09:10:00', 8, 1, 1, 1),
    ('2023-05-03', '09:20:00', 16, 1, 2, 1),
    ('2023-05-08', '09:10:00', 20, 1, 1, 1),
    ('2023-05-10', '09:20:00', 20, 1, 2, 1),
    ('2023-05-01', '10:20:00', 30, 11, 1, 3),
    ('2023-05-01', '10:40:00', 40, 11, 2, 3),
    ('2023-05-01', '11:20:00', 60, 11, 3, 3),
    ('2023-05-01', '13:30:00', 30, 11, 4, 3),
    ('2023-05-01', '13:50:00', 30, 11, 5, 3),
    ('2023-05-01', '16:30:00', 100, NULL, 1, 3),
    ('2023-05-03', '10:20:00', 30, 12, 1, 3),
    ('2023-05-03', '10:40:00', 40, 12, 2, 3),
    ('2023-05-03', '11:20:00', 60, 12, 3, 3),
    ('2023-05-03', '13:30:00', 30, 12, 4, 3),
    ('2023-05-03', '13:50:00', 30, 12, 5, 3),
    ('2023-05-03', '16:30:00', 100, NULL, 1, 3),
    ('2023-05-05', '10:20:00', 30, 13, 1, 3),
    ('2023-05-05', '10:40:00', 40, 13, 2, 3),
    ('2023-05-05', '11:20:00', 60, 13, 3, 3),
    ('2023-05-05', '13:30:00', 30, 13, 4, 3),
    ('2023-05-05', '13:50:00', 30, 13, 5, 3),
    ('2023-05-05', '16:30:00', 100, NULL, 1, 3),
    ('2023-05-08', '10:20:00', 30, 11, 1, 3),
    ('2023-05-08', '10:40:00', 40, 11, 2, 3),
    ('2023-05-08', '11:20:00', 60, 11, 3, 3),
    ('2023-05-08', '13:30:00', 30, 11, 4, 3),
    ('2023-05-08', '13:50:00', 30, 11, 5, 3),
    ('2023-05-08', '16:30:00', 100, NULL, 1, 3),
    ('2023-05-10', '10:20:00', 30, 12, 1, 3),
    ('2023-05-10', '10:40:00', 40, 12, 2, 3),
    ('2023-05-10', '11:20:00', 60, 12, 3, 3),
    ('2023-05-10', '13:30:00', 30, 12, 4, 3),
    ('2023-05-10', '13:50:00', 30, 12, 5, 3),
    ('2023-05-10', '16:30:00', 100, NULL, 1, 3),
    ('2023-05-12', '10:20:00', 30, 13, 1, 3),
    ('2023-05-12', '10:40:00', 40, 13, 2, 3),
    ('2023-05-12', '11:20:00', 60, 13, 3, 3),
    ('2023-05-12', '13:30:00', 30, 13, 4, 3),
    ('2023-05-12', '13:50:00', 30, 13, 5, 3),
    ('2023-05-12', '16:30:00', 100, NULL, 1, 3),
    ('2023-05-08', '13:30:00', 10, 9, 17, 4),
    ('2023-05-08', '14:00:00', 15, 9, 18, 4),
    ('2023-05-10', '13:30:00', 10, 10, 17, 4),
    ('2023-05-10', '14:00:00', 15, 10, 18, 4),
    ('2023-05-12', '13:30:00', 10, 9, 17, 4),
    ('2023-05-12', '14:00:00', 15, 9, 18, 4);

INSERT INTO REST (REST_START_DATE, REST_END_DATE, REST_START_TIME, REST_END_TIME, SLEEP_ID, USER_ID)
VALUES
    ('2023-05-02', '2023-05-02', '00:30:00', '07:30:00', 2, 1),
    ('2023-05-03', '2023-05-03', '00:30:00', '07:30:00', 2, 1),
    ('2023-05-04', '2023-05-04', '00:30:00', '07:30:00', 2, 1),
    ('2023-05-05', '2023-05-05', '00:30:00', '07:30:00', 2, 1),
    ('2023-05-06', '2023-05-06', '00:30:00', '07:30:00', 2, 1),
    ('2023-05-01', '2023-05-02', '22:30:00', '06:30:00', 4, 2),
    ('2023-05-02', '2023-05-03', '22:30:00', '06:30:00', 4, 2),
    ('2023-05-03', '2023-05-04', '22:30:00', '06:30:00', 4, 2),
    ('2023-05-04', '2023-05-05', '22:30:00', '06:30:00', 4, 2),
    ('2023-05-05', '2023-05-06', '22:30:00', '06:30:00', 4, 2),
    ('2023-05-02', '2023-05-02', '03:30:00', '09:30:00', 6, 4),
    ('2023-05-03', '2023-05-03', '03:30:00', '09:30:00', 6, 4),
    ('2023-05-04', '2023-05-04', '03:30:00', '09:30:00', 6, 4),
    ('2023-05-05', '2023-05-05', '03:30:00', '09:30:00', 6, 4),
    ('2023-05-06', '2023-05-06', '03:30:00', '09:30:00', 6, 4);

INSERT INTO FOOD (FOOD_DATE, FOOD_TIME, FOOD_COUNT, DIET_ID, MEAL_NAME, FOODSTUFF_ID, USER_ID)
VALUES
    ('2023-05-01', '10:00:00', 2, 3, 'BREAKFAST', 5, 1),
    ('2023-05-01', '12:00:00', 2, 3, 'LUNCH', 12, 1),
    ('2023-05-01', '17:00:00', 1, 3, 'DINNER', 8, 1),
    ('2023-05-01', '10:00:00', 2, 3, 'BREAKFAST', 5, 1),
    ('2023-05-01', '12:00:00', 2, 3, 'LUNCH', 12, 1),
    ('2023-05-01', '17:00:00', 1, 3, 'DINNER', 8, 1);

ALTER TABLE USER
    ADD CONSTRAINT FOREIGN KEY (PLAN_ID) REFERENCES PLAN(PLAN_ID);

ALTER TABLE PLAN
    ADD CONSTRAINT FOREIGN KEY (USER_ID) REFERENCES USER(USER_ID),
    ADD CONSTRAINT FOREIGN KEY (REGIMEN_ID) REFERENCES REGIMEN(REGIMEN_ID),
    ADD CONSTRAINT FOREIGN KEY (SLEEP_ID) REFERENCES SLEEP(SLEEP_ID),
    ADD CONSTRAINT FOREIGN KEY (DIET_ID) REFERENCES DIET(DIET_ID);

ALTER TABLE MEASUREMENT
    ADD CONSTRAINT FOREIGN KEY (USER_ID) REFERENCES USER(USER_ID);

ALTER TABLE WORKOUT
    ADD CONSTRAINT FOREIGN KEY (REGIMEN_ID) REFERENCES REGIMEN(REGIMEN_ID);

ALTER TABLE ROUTINE
    ADD CONSTRAINT FOREIGN KEY (WORKOUT_ID) REFERENCES WORKOUT(WORKOUT_ID),
    ADD CONSTRAINT FOREIGN KEY (EXERCISE_ID) REFERENCES EXERCISE(EXERCISE_ID);

ALTER TABLE PERFORMANCE
    ADD CONSTRAINT FOREIGN KEY (WORKOUT_ID) REFERENCES WORKOUT(WORKOUT_ID),
    ADD CONSTRAINT FOREIGN KEY (EXERCISE_ID) REFERENCES EXERCISE(EXERCISE_ID);

ALTER TABLE REST
    ADD CONSTRAINT FOREIGN KEY (SLEEP_ID) REFERENCES SLEEP(SLEEP_ID),
    ADD CONSTRAINT FOREIGN KEY (USER_ID) REFERENCES USER(USER_ID);

ALTER TABLE MEAL
    ADD CONSTRAINT FOREIGN KEY (DIET_ID) REFERENCES DIET(DIET_ID),
    ADD CONSTRAINT FOREIGN KEY (NUTRITION_ID) REFERENCES NUTRITION(NUTRITION_ID);

ALTER TABLE FOODSTUFF
    ADD CONSTRAINT FOREIGN KEY (NUTRITION_ID) REFERENCES NUTRITION(NUTRITION_ID);

ALTER TABLE FOOD
    ADD CONSTRAINT FOREIGN KEY (DIET_ID, MEAL_NAME) REFERENCES MEAL(DIET_ID, MEAL_NAME),
    ADD CONSTRAINT FOREIGN KEY (FOODSTUFF_ID) REFERENCES FOODSTUFF(FOODSTUFF_ID),
    ADD CONSTRAINT FOREIGN KEY (USER_ID) REFERENCES USER(USER_ID);