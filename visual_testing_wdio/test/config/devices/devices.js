const devicesData = [
    {
        type: 'iOS',
        devices:[
            {
                name: "iPhone SE",
                resolution:{
                    width: 375,
                    height: 667
                },
                breakPoint: 4
            },
            {
                name: "iPhone 11",
                resolution:{
                    width: 414,
                    height: 896
                },
                breakPoint: 4
            },
            {
                name: "iPhone 14",
                resolution:{
                    width: 390,
                    height: 844
                },
                breakPoint: 4
            }
        ]
    },
    {
        type: 'iPadOS',
        devices:[
            {
                name: "iPad Air",
                resolution:{
                    width: 820,
                    height: 1180
                },
                breakPoint: 3
            },
            {
                name: "iPad Pro - Landscape",
                resolution:{
                    width: 1366,
                    height: 1080
                },
                breakPoint: 2
            }
        ]
    },
    {
        type: 'AndroidMobile',
        devices:[
            {
                name: "Samsung Galaxy S10",
                resolution:{
                    width: 360,
                    height: 740
                },
                breakPoint: 4
            }
        ]
    },
    {
        type: 'AndroidTablet',
        devices:[
            {
                name: "Samsung Galaxy A8",
                resolution:{
                    width: 800,
                    height: 1200
                },
                breakPoint: 3
            }
        ]
    },
    {
        type: 'Desktop',
        devices:[
            {
                name: "Desktop",
                resolution:{
                    width: 1980,
                    height: 1080
                },
                breakPoint: 1
            }
        ]
    }
]

module.exports =  devicesData 
