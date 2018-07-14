package me.rayzr522.hello;

import java.util.List;
import java.util.ArrayList;
import me.rayzr522.hello.structs.Generator;

public class ArrayUtils {
    public static <T> List<T> generate(int length, Generator<T> generator) {
        if (length < 0) {
            throw new IllegalArgumentException("Length must be >= 0!");
        }

        List<T> out = new ArrayList<>(length);

        for (int i = 0; i < length; i++) {
            out.add(generator.generate(i, out));
        }

        return out;
    }
}
