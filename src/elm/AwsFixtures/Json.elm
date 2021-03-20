module Json exposing (securityGroups, instances)


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
                            \"GroupName\": \"",
                            \"Tenancy\": \"default\"
                        },
                        \"PrivateDnsName\": \"ip-42-0-5-157.eu-west-1.compute.internal\",
                        \"PrivateIpAddress\": \"42.0.5.157\",
                        \"ProductCodes\": [],
                        \"PublicDnsName\": \"",
                        \"State\": {
                            \"Code\": 16,
                            \"Name\": \"running\"
                        },
                        \"StateTransitionReason\": \"",
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
                                \"Description\": \"",
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