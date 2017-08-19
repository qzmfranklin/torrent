#include <string>
#include <google/protobuf/text_format.h>

#include "src/proto/examples/address.pb.h"
#include "src/proto/examples/person.pb.h"
#include "src/proto/examples/zip_code.pb.h"

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

using namespace google::protobuf;

int MAIN(int argc, char *argv[])
{
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    demo::ZipCode *zipcode = new demo::ZipCode();
    zipcode->set_code("98761");

    demo::Address *addr = new demo::Address();
    addr->set_city("Kupertinew");
    addr->set_allocated_zip_code(zipcode);

    demo::Person *john = new demo::Person();
    john->set_id(1234);
    john->set_name("John Doe");
    john->set_email("jdoe@example.com");
    john->set_allocated_address(addr);

    std::string str;
    TextFormat::PrintToString(*john, &str);
    std::cout << str << std::endl;

    /*
     * Don't free addr and zipcode here because their ownership is transferred,
     * to the containing object by the set_allocated_xyz() methods.  As a
     * result, these objects are freed by the dtor of john.
     *
     * Interestingly, failing to do so will result in heap-use-after-free error
     * as reported by the LLVM Memory Sanitizer.
     */
    delete john;

    ShutdownProtobufLibrary();

    return 0;
}
