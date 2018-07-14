package me.rayzr522.hello.structs;

import java.util.List;

public interface Generator<T> {
    T generate(int index, List<T> current);
}
