
## Stoftanza StringArt Essentials

For programmers in a hurry, here's a flash description of Softanza's StringArt essential features:

1. **Goal**: Generate string art representations of text or predefined paintings.

2. **Simplest Usage**: Use the `StringArt()` function
   ```ring
   ? StringArt("Hello")
   #-->
   /*
   ██░░░██ ███████ ██░░░░░ ██░░░░░ ░▄███▄░
   ██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▀░▀██
   ███████ █████░░ ██░░░░░ ██░░░░░ ██░░░██
   ██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▄░▄██
   ██░░░██ ███████ ███████ ███████ ░▀███▀░ 
   */
   ```

3. **Object-Oriented Approach**: Use the `stzStringArt` class
   ```ring
   oArt = new stzStringArt("Ring")
   oArt.SetStyle(:flower)
   ? oArt.Artify()
   ```

4. **Two Types of String Art**:
   - Text-based: As shown in points 2 and 3
   - Predefined Paintings: Use special syntax
     ```ring
     ? StringArt("#{Tree}")
     #-->
     /*
         🍃
        🍃🍃
       🍃🍃🍃
      🍃🍃🍃🍃
     🍃🍃🍃🍃🍃
         ┃━┃
         ┃━┃
     */
     ```

5. **Styles**: Multiple styles available (e.g., retro, neon, geo, flower). Change using `SetStyle()` or `SetDefaultStringArtStyle()`.

6. **Boxify**: Create boxed versions of string art using `StringArtBoxified()` or the `Boxify()` method.

These points cover the essential aspects of Softanza's StringArt feature, allowing programmers to quickly start using it in their projects.