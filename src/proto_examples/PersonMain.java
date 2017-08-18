package proto_examples;

import demo.AddressOuterClass.Address;
import demo.PersonOuterClass.Person;
import demo.ZipCodeOuterClass.ZipCode;

/*
 * This program should print the following text:
 *      name: "John Doe"
 *      id: 1234
 *      email: "jdoe@example.com"
 *      address {
 *        city: "Kupertinew"
 *        zip_code {
 *          code: "98761"
 *        }
 *      }
 */
class PersonMain {
    public static void main(String args[]) {
        Person john = Person.newBuilder()
                .setName("John Doe")
                .setId(1234)
                .setEmail("jdoe@example.com")
                .setAddress(Address.newBuilder()
                        .setCity("Kupertinew")
                        .setZipCode(ZipCode.newBuilder()
                                .setCode("98761")
                                .build()
                        )
                        .build()
                )
                .build();
        System.out.print(john.toString());
    }
}
