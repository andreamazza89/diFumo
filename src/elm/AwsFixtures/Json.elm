module AwsFixtures.Json exposing
    ( instances
    , securityGroups
    , subnets
    , vpcs
    , routeTables)


vpcs : String
vpcs =
    """
    {
        \"Vpcs\": [
            {
                \"CidrBlock\": \"42.0.0.0/16\",
                \"DhcpOptionsId\": \"dopt-aac093cc\",
                \"State\": \"available\",
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\",
                \"InstanceTenancy\": \"default\",
                \"CidrBlockAssociationSet\": [
                    {
                        \"AssociationId\": \"vpc-cidr-assoc-0911856de589dc8ba\",
                        \"CidrBlock\": \"42.0.0.0/16\",
                        \"CidrBlockState\": {
                            \"State\": \"associated\"
                        }
                    }
                ],
                \"IsDefault\": false,
                \"Tags\": [
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    },
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah VPC\"
                    }
                ]
            }
        ]
    }
    """


securityGroups : String
securityGroups =
    """
    {
        \"SecurityGroups\": [
            {
                \"Description\": \"default VPC security group\",
                \"GroupName\": \"default\",
                \"IpPermissions\": [],
                \"OwnerId\": \"062881346168\",
                \"GroupId\": \"sg-049f623e368dd4e98\",
                \"IpPermissionsEgress\": [],
                \"VpcId\": \"vpc-02a34f69639e5d566\"
            },
            {
                \"Description\": \"Managed by Terraform\",
                \"GroupName\": \"terraform-20200515152731786100000001\",
                \"IpPermissions\": [
                    {
                        \"FromPort\": 443,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"0.0.0.0/0\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 443,
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"OwnerId\": \"062881346168\",
                \"GroupId\": \"sg-06ddd2ab91bc0de9a\",
                \"IpPermissionsEgress\": [
                    {
                        \"FromPort\": 8080,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"42.0.0.0/16\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 8080,
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"Tags\": [
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    }
                ],
                \"VpcId\": \"vpc-02a34f69639e5d566\"
            },
            {
                \"Description\": \"Managed by Terraform\",
                \"GroupName\": \"antivirus-api\",
                \"IpPermissions\": [
                    {
                        \"FromPort\": 80,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 80,
                        \"UserIdGroupPairs\": [
                            {
                                \"GroupId\": \"sg-0977fe939bab81b7a\",
                                \"UserId\": \"062881346168\"
                            }
                        ]
                    }
                ],
                \"OwnerId\": \"062881346168\",
                \"GroupId\": \"sg-0977fe939bab81b7a\",
                \"IpPermissionsEgress\": [
                    {
                        \"FromPort\": 80,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 80,
                        \"UserIdGroupPairs\": [
                            {
                                \"GroupId\": \"sg-0977fe939bab81b7a\",
                                \"UserId\": \"062881346168\"
                            }
                        ]
                    }
                ],
                \"VpcId\": \"vpc-02a34f69639e5d566\"
            },
            {
                \"Description\": \"Managed by Terraform\",
                \"GroupName\": \"bastion\",
                \"IpPermissions\": [],
                \"OwnerId\": \"062881346168\",
                \"GroupId\": \"sg-09f397e7063d1df77\",
                \"IpPermissionsEgress\": [
                    {
                        \"IpProtocol\": \"-1\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"42.0.0.0/16\",
                                \"Description\": \"Allow outbound traffic within the VPC\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [
                            {
                                \"Description\": \"Allow outbound traffic to the VPC endpoints\",
                                \"PrefixListId\": \"pl-6da54004\"
                            }
                        ],
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"VpcId\": \"vpc-02a34f69639e5d566\"
            },
            {
                \"Description\": \"Managed by Terraform\",
                \"GroupName\": \"mrdp-oprah-ecs-backend-service-security-group-development\",
                \"IpPermissions\": [
                    {
                        \"FromPort\": 8080,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"42.0.0.0/16\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 8080,
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"OwnerId\": \"062881346168\",
                \"GroupId\": \"sg-0c67182082dfb4836\",
                \"IpPermissionsEgress\": [
                    {
                        \"FromPort\": 80,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"0.0.0.0/0\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 80,
                        \"UserIdGroupPairs\": []
                    },
                    {
                        \"FromPort\": 5432,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"0.0.0.0/0\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 5432,
                        \"UserIdGroupPairs\": []
                    },
                    {
                        \"FromPort\": 443,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"0.0.0.0/0\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 443,
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"Tags\": [
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah fargate backend service security group\"
                    },
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    },
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    }
                ],
                \"VpcId\": \"vpc-02a34f69639e5d566\"
            },
            {
                \"Description\": \"Managed by Terraform\",
                \"GroupName\": \"terraform-20200129154733212400000001\",
                \"IpPermissions\": [
                    {
                        \"FromPort\": 5432,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"42.0.0.0/16\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 5432,
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"OwnerId\": \"062881346168\",
                \"GroupId\": \"sg-0e6877f983f64501c\",
                \"IpPermissionsEgress\": [
                    {
                        \"FromPort\": 5432,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"42.0.0.0/16\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 5432,
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"Tags\": [
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    },
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah database security group\"
                    }
                ],
                \"VpcId\": \"vpc-02a34f69639e5d566\"
            },
            {
                \"Description\": \"Managed by Terraform\",
                \"GroupName\": \"vpc_interface_endpoints\",
                \"IpPermissions\": [
                    {
                        \"FromPort\": 443,
                        \"IpProtocol\": \"tcp\",
                        \"IpRanges\": [
                            {
                                \"CidrIp\": \"42.0.0.0/16\",
                                \"Description\": \"Allow ingress from within VPC to VPC Endpoints\"
                            }
                        ],
                        \"Ipv6Ranges\": [],
                        \"PrefixListIds\": [],
                        \"ToPort\": 443,
                        \"UserIdGroupPairs\": []
                    }
                ],
                \"OwnerId\": \"062881346168\",
                \"GroupId\": \"sg-0fa2e35964a5a56d9\",
                \"IpPermissionsEgress\": [],
                \"VpcId\": \"vpc-02a34f69639e5d566\"
            }
        ]
    }
    """


instances : String
instances =
    """
    {
        \"Reservations\": [
            {
                \"Groups\": [],
                \"Instances\": [
                    {
                        \"AmiLaunchIndex\": 0,
                        \"ImageId\": \"ami-079d9017cb651564d\",
                        \"InstanceId\": \"i-09af59bfa9c27a8ea\",
                        \"InstanceType\": \"t2.micro\",
                        \"LaunchTime\": \"2021-03-17T09:51:57+00:00\",
                        \"Monitoring\": {
                            \"State\": \"enabled\"
                        },
                        \"Placement\": {
                            \"AvailabilityZone\": \"eu-west-1a\",
                            \"GroupName\": \"\",
                            \"Tenancy\": \"default\"
                        },
                        \"PrivateDnsName\": \"ip-42-0-5-157.eu-west-1.compute.internal\",
                        \"PrivateIpAddress\": \"42.0.5.157\",
                        \"ProductCodes\": [],
                        \"PublicDnsName\": \"\",
                        \"State\": {
                            \"Code\": 16,
                            \"Name\": \"running\"
                        },
                        \"StateTransitionReason\": \"\",
                        \"SubnetId\": \"subnet-06b385372a02a26f9\",
                        \"VpcId\": \"vpc-02a34f69639e5d566\",
                        \"Architecture\": \"x86_64\",
                        \"BlockDeviceMappings\": [
                            {
                                \"DeviceName\": \"/dev/xvda\",
                                \"Ebs\": {
                                    \"AttachTime\": \"2021-03-17T09:51:58+00:00\",
                                    \"DeleteOnTermination\": true,
                                    \"Status\": \"attached\",
                                    \"VolumeId\": \"vol-093ac0f1c3a77dd3e\"
                                }
                            }
                        ],
                        \"ClientToken\": \"F4A378F2-2C38-4271-AE6E-61F648A77201\",
                        \"EbsOptimized\": false,
                        \"EnaSupport\": true,
                        \"Hypervisor\": \"xen\",
                        \"IamInstanceProfile\": {
                            \"Arn\": \"arn:aws:iam::062881346168:instance-profile/bastion\",
                            \"Id\": \"AIPAQ5JAFGJ4ILCLACAF2\"
                        },
                        \"NetworkInterfaces\": [
                            {
                                \"Attachment\": {
                                    \"AttachTime\": \"2021-03-17T09:51:57+00:00\",
                                    \"AttachmentId\": \"eni-attach-05c5b71034cc753ca\",
                                    \"DeleteOnTermination\": true,
                                    \"DeviceIndex\": 0,
                                    \"Status\": \"attached\",
                                    \"NetworkCardIndex\": 0
                                },
                                \"Description\": \"\",
                                \"Groups\": [
                                    {
                                        \"GroupName\": \"bastion\",
                                        \"GroupId\": \"sg-09f397e7063d1df77\"
                                    }
                                ],
                                \"Ipv6Addresses\": [],
                                \"MacAddress\": \"06:73:de:c2:a4:f1\",
                                \"NetworkInterfaceId\": \"eni-020475b479561b453\",
                                \"OwnerId\": \"062881346168\",
                                \"PrivateDnsName\": \"ip-42-0-5-157.eu-west-1.compute.internal\",
                                \"PrivateIpAddress\": \"42.0.5.157\",
                                \"PrivateIpAddresses\": [
                                    {
                                        \"Primary\": true,
                                        \"PrivateDnsName\": \"ip-42-0-5-157.eu-west-1.compute.internal\",
                                        \"PrivateIpAddress\": \"42.0.5.157\"
                                    }
                                ],
                                \"SourceDestCheck\": true,
                                \"Status\": \"in-use\",
                                \"SubnetId\": \"subnet-06b385372a02a26f9\",
                                \"VpcId\": \"vpc-02a34f69639e5d566\",
                                \"InterfaceType\": \"interface\"
                            }
                        ],
                        \"RootDeviceName\": \"/dev/xvda\",
                        \"RootDeviceType\": \"ebs\",
                        \"SecurityGroups\": [
                            {
                                \"GroupName\": \"bastion\",
                                \"GroupId\": \"sg-09f397e7063d1df77\"
                            }
                        ],
                        \"SourceDestCheck\": true,
                        \"Tags\": [
                            {
                                \"Key\": \"monitoring\",
                                \"Value\": \"disabled\"
                            },
                            {
                                \"Key\": \"family\",
                                \"Value\": \"oprah\"
                            },
                            {
                                \"Key\": \"env\",
                                \"Value\": \"development\"
                            },
                            {
                                \"Key\": \"Name\",
                                \"Value\": \"bastion\"
                            }
                        ],
                        \"VirtualizationType\": \"hvm\",
                        \"CpuOptions\": {
                            \"CoreCount\": 1,
                            \"ThreadsPerCore\": 1
                        },
                        \"CapacityReservationSpecification\": {
                            \"CapacityReservationPreference\": \"open\"
                        },
                        \"HibernationOptions\": {
                            \"Configured\": false
                        },
                        \"MetadataOptions\": {
                            \"State\": \"applied\",
                            \"HttpTokens\": \"required\",
                            \"HttpPutResponseHopLimit\": 1,
                            \"HttpEndpoint\": \"enabled\"
                        },
                        \"EnclaveOptions\": {
                            \"Enabled\": false
                        }
                    }
                ],
                \"OwnerId\": \"062881346168\",
                \"ReservationId\": \"r-08a5672123fe3edf1\"
            }
        ]
    }
    """


subnets : String
subnets =
    """
    {
        \"Subnets\": [
            {
                \"AvailabilityZone\": \"eu-west-1a\",
                \"AvailabilityZoneId\": \"euw1-az2\",
                \"AvailableIpAddressCount\": 2036,
                \"CidrBlock\": \"42.0.0.0/21\",
                \"DefaultForAz\": false,
                \"MapPublicIpOnLaunch\": false,
                \"MapCustomerOwnedIpOnLaunch\": false,
                \"State\": \"available\",
                \"SubnetId\": \"subnet-06b385372a02a26f9\",
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\",
                \"AssignIpv6AddressOnCreation\": false,
                \"Ipv6CidrBlockAssociationSet\": [],
                \"Tags\": [
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    },
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah private subnet a\"
                    }
                ],
                \"SubnetArn\": \"arn:aws:ec2:eu-west-1:062881346168:subnet/subnet-06b385372a02a26f9\"
            },
            {
                \"AvailabilityZone\": \"eu-west-1b\",
                \"AvailabilityZoneId\": \"euw1-az3\",
                \"AvailableIpAddressCount\": 2042,
                \"CidrBlock\": \"42.0.24.0/21\",
                \"DefaultForAz\": false,
                \"MapPublicIpOnLaunch\": true,
                \"MapCustomerOwnedIpOnLaunch\": false,
                \"State\": \"available\",
                \"SubnetId\": \"subnet-06b6493e0504e3071\",
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\",
                \"AssignIpv6AddressOnCreation\": false,
                \"Ipv6CidrBlockAssociationSet\": [],
                \"Tags\": [
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    },
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah public subnet b\"
                    }
                ],
                \"SubnetArn\": \"arn:aws:ec2:eu-west-1:062881346168:subnet/subnet-06b6493e0504e3071\"
            },
            {
                \"AvailabilityZone\": \"eu-west-1a\",
                \"AvailabilityZoneId\": \"euw1-az2\",
                \"AvailableIpAddressCount\": 2041,
                \"CidrBlock\": \"42.0.16.0/21\",
                \"DefaultForAz\": false,
                \"MapPublicIpOnLaunch\": true,
                \"MapCustomerOwnedIpOnLaunch\": false,
                \"State\": \"available\",
                \"SubnetId\": \"subnet-0926c582dfc511c89\",
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\",
                \"AssignIpv6AddressOnCreation\": false,
                \"Ipv6CidrBlockAssociationSet\": [],
                \"Tags\": [
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah public subnet a\"
                    },
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    }
                ],
                \"SubnetArn\": \"arn:aws:ec2:eu-west-1:062881346168:subnet/subnet-0926c582dfc511c89\"
            },
            {
                \"AvailabilityZone\": \"eu-west-1b\",
                \"AvailabilityZoneId\": \"euw1-az3\",
                \"AvailableIpAddressCount\": 2038,
                \"CidrBlock\": \"42.0.8.0/21\",
                \"DefaultForAz\": false,
                \"MapPublicIpOnLaunch\": false,
                \"MapCustomerOwnedIpOnLaunch\": false,
                \"State\": \"available\",
                \"SubnetId\": \"subnet-0c8587ae21dd2f18a\",
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\",
                \"AssignIpv6AddressOnCreation\": false,
                \"Ipv6CidrBlockAssociationSet\": [],
                \"Tags\": [
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    },
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah private subnet b\"
                    }
                ],
                \"SubnetArn\": \"arn:aws:ec2:eu-west-1:062881346168:subnet/subnet-0c8587ae21dd2f18a\"
            }
        ]
    }
    """


routeTables : String
routeTables =
    """
    {
        \"RouteTables\": [
            {
                \"Associations\": [
                    {
                        \"Main\": true,
                        \"RouteTableAssociationId\": \"rtbassoc-02e6a4c0d08451cfa\",
                        \"RouteTableId\": \"rtb-0ca5500ccd19357fc\",
                        \"AssociationState\": {
                            \"State\": \"associated\"
                        }
                    }
                ],
                \"PropagatingVgws\": [],
                \"RouteTableId\": \"rtb-0ca5500ccd19357fc\",
                \"Routes\": [
                    {
                        \"DestinationCidrBlock\": \"42.0.0.0/16\",
                        \"GatewayId\": \"local\",
                        \"Origin\": \"CreateRouteTable\",
                        \"State\": \"active\"
                    }
                ],
                \"Tags\": [],
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\"
            },
            {
                \"Associations\": [
                    {
                        \"Main\": false,
                        \"RouteTableAssociationId\": \"rtbassoc-0361d2fb151daaff6\",
                        \"RouteTableId\": \"rtb-04d93e9f6bf4e9433\",
                        \"SubnetId\": \"subnet-0c8587ae21dd2f18a\",
                        \"AssociationState\": {
                            \"State\": \"associated\"
                        }
                    },
                    {
                        \"Main\": false,
                        \"RouteTableAssociationId\": \"rtbassoc-01928583a47ae5440\",
                        \"RouteTableId\": \"rtb-04d93e9f6bf4e9433\",
                        \"SubnetId\": \"subnet-06b385372a02a26f9\",
                        \"AssociationState\": {
                            \"State\": \"associated\"
                        }
                    }
                ],
                \"PropagatingVgws\": [],
                \"RouteTableId\": \"rtb-04d93e9f6bf4e9433\",
                \"Routes\": [
                    {
                        \"DestinationCidrBlock\": \"42.0.0.0/16\",
                        \"GatewayId\": \"local\",
                        \"Origin\": \"CreateRouteTable\",
                        \"State\": \"active\"
                    },
                    {
                        \"DestinationCidrBlock\": \"0.0.0.0/0\",
                        \"NatGatewayId\": \"nat-0bd293ef912fb8bfb\",
                        \"Origin\": \"CreateRoute\",
                        \"State\": \"active\"
                    },
                    {
                        \"DestinationPrefixListId\": \"pl-6da54004\",
                        \"GatewayId\": \"vpce-058d988a9f24d2a53\",
                        \"Origin\": \"CreateRoute\",
                        \"State\": \"active\"
                    }
                ],
                \"Tags\": [
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah private route table\"
                    },
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    },
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    }
                ],
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\"
            },
            {
                \"Associations\": [
                    {
                        \"Main\": false,
                        \"RouteTableAssociationId\": \"rtbassoc-06f68e55e631ec8a1\",
                        \"RouteTableId\": \"rtb-0c4deb756e5396492\",
                        \"SubnetId\": \"subnet-0926c582dfc511c89\",
                        \"AssociationState\": {
                            \"State\": \"associated\"
                        }
                    },
                    {
                        \"Main\": false,
                        \"RouteTableAssociationId\": \"rtbassoc-00ef5b351e3c87c96\",
                        \"RouteTableId\": \"rtb-0c4deb756e5396492\",
                        \"SubnetId\": \"subnet-06b6493e0504e3071\",
                        \"AssociationState\": {
                            \"State\": \"associated\"
                        }
                    }
                ],
                \"PropagatingVgws\": [],
                \"RouteTableId\": \"rtb-0c4deb756e5396492\",
                \"Routes\": [
                    {
                        \"DestinationCidrBlock\": \"42.0.0.0/16\",
                        \"GatewayId\": \"local\",
                        \"Origin\": \"CreateRouteTable\",
                        \"State\": \"active\"
                    },
                    {
                        \"DestinationCidrBlock\": \"0.0.0.0/0\",
                        \"GatewayId\": \"igw-0bd697ec0e7462be4\",
                        \"Origin\": \"CreateRoute\",
                        \"State\": \"active\"
                    }
                ],
                \"Tags\": [
                    {
                        \"Key\": \"family\",
                        \"Value\": \"oprah\"
                    },
                    {
                        \"Key\": \"Name\",
                        \"Value\": \"Oprah public route table\"
                    },
                    {
                        \"Key\": \"env\",
                        \"Value\": \"development\"
                    }
                ],
                \"VpcId\": \"vpc-02a34f69639e5d566\",
                \"OwnerId\": \"062881346168\"
            }
        ]
    }
    """
