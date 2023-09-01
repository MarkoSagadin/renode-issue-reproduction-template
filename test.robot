*** Settings ***
Suite Setup                   Setup
Suite Teardown                Teardown
Test Setup                    Reset Emulation
Test Teardown                 Test Teardown
Resource                      ${RENODEKEYWORDS}

*** Variables ***
${SCRIPT}                     ${CURDIR}/test.resc
${UART}                       sysbus.uart0

*** Keywords ***
Load Script
    Execute Script            ${SCRIPT}
    Create Terminal Tester    ${UART}


*** Test Cases ***
Should Handle LED and Button
    Load Script
    Create LED Tester         sysbus.gpio0.led  defaultTimeout=0

    Start Emulation
    Wait For Line On Uart     Booting Zephyr OS
    Wait For Line On Uart     Press the button

    Assert LED State          true
    Execute Command           sysbus.gpio0.button Press
    Sleep           1s
    Assert LED State          false
    Execute Command           sysbus.gpio0.button Release
    Sleep           1s
    # TODO: those sleeps shouldn't be necessary!
    Assert LED State          true

Should triger interrupt on Button press
    Load Script
    Create LED Tester               sysbus.gpio0.led  defaultTimeout=0

    Start Emulation
    Wait For Line On Uart           Booting Zephyr OS
    Wait For Line On Uart           Press the button

    Execute Command                 sysbus.gpio0.button Press

    ${p}=  Wait For Next Line On Uart   timeout=3

    Should Start With               ${p}    "Button pressed at"
