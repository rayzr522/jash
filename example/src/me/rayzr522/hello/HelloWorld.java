package me.rayzr522.hello;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, world!");

        if (args.length < 1) {
            System.out.println("Enter a number of digits to generate for Fibonacci's series.");
            return;
        }

        int num;
        try {
            num = Integer.parseInt(args[0]);
        } catch (NumberFormatException e) {
            System.err.println("Please enter a valid number!");
            System.exit(1);
            return;
        }

        System.out.println("First " + num + " digit(s)...");
        fibonacci(num).forEach(System.out::println);
    }

    private static List<Long> fibonacci(int length) {
        return ArrayUtils.generate(length, (i, current) -> i < 2 ? 1 : current.get(i - 1) + current.get(i - 2));
    }
}
