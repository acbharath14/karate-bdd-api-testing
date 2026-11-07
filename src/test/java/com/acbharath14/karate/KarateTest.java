package com.acbharath14.karate;

import com.intuit.karate.junit5.Karate;

/**
 * JUnit 5 entry point for every Karate feature file under
 * {@code src/test/resources/features}.
 *
 * <p>Karate needs no step definitions: each {@code .feature} file is a
 * complete test, written in Given-When-Then. This runner just points
 * Karate at the folder. Add a feature file, run {@code mvn test}, and
 * it runs.</p>
 *
 * <p>Run a subset by tag: {@code mvn test -Dkarate.tags=@smoke} runs
 * only scenarios tagged {@code @smoke}.</p>
 */
class KarateTest {

    @Karate.Test
    Karate runAll() {
        Karate karate = Karate.run("classpath:features").relativeTo(getClass());
        String tags = System.getProperty("karate.tags");
        if (tags != null && !tags.isBlank()) {
            karate.tags(tags);
        }
        return karate;
    }
}
